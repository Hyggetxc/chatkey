import ApplicationServices
import Foundation

final class EventTapService {
    private struct RuntimeState {
        var settings = AppSettings()
        var currentApp: AppDescriptor?
        var rules: [AppRule] = []
        var permissionTrusted = false
    }

    private let stateLock = NSLock()
    private var state = RuntimeState()

    private let actionDispatcher: ActionDispatcher
    private let diagnostics: DiagnosticsCenter

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private static let tapCallback: CGEventTapCallBack = { proxy, type, event, userInfo in
        guard let userInfo else {
            return Unmanaged.passUnretained(event)
        }

        let service = Unmanaged<EventTapService>.fromOpaque(userInfo).takeUnretainedValue()
        return service.handleEvent(proxy: proxy, type: type, event: event)
    }

    init(
        actionDispatcher: ActionDispatcher,
        diagnostics: DiagnosticsCenter
    ) {
        self.actionDispatcher = actionDispatcher
        self.diagnostics = diagnostics
    }

    func updateSettings(_ settings: AppSettings) {
        withStateLock {
            $0.settings = settings
        }

        reevaluateTapLifecycle()
    }

    func updateRules(_ rules: [AppRule]) {
        withStateLock {
            $0.rules = rules
        }
    }

    func updateCurrentApp(_ app: AppDescriptor?) {
        withStateLock {
            $0.currentApp = app
        }
    }

    func updatePermissionTrusted(_ isTrusted: Bool) {
        withStateLock {
            $0.permissionTrusted = isTrusted
        }

        reevaluateTapLifecycle()
    }

    func startIfNeeded() {
        reevaluateTapLifecycle()
    }

    func stop() {
        guard let eventTap else {
            return
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }

        CFMachPortInvalidate(eventTap)
        self.eventTap = nil
    }

    private func reevaluateTapLifecycle() {
        let snapshot = currentState()

        guard snapshot.permissionTrusted else {
            stop()
            reportListenerStatus(.inactive(.missingPermission))
            return
        }

        guard snapshot.settings.isEnabled else {
            stop()
            reportListenerStatus(.inactive(.disabledByUser))
            return
        }

        if eventTap == nil {
            startEventTap()
        } else {
            reportListenerStatus(.active)
        }
    }

    private func startEventTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: Self.tapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            reportListenerStatus(.failed("Failed to create keyboard event tap."))
            Task { @MainActor [diagnostics] in
                diagnostics.recordError("Failed to create keyboard event tap.")
            }
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        self.eventTap = eventTap
        self.runLoopSource = runLoopSource
        reportListenerStatus(.active)
    }

    private func handleEvent(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }

            reportListenerStatus(.active)
            return Unmanaged.passUnretained(event)

        case .keyDown:
            break

        default:
            return Unmanaged.passUnretained(event)
        }

        if actionDispatcher.isSyntheticEvent(event) {
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let decision = KeyEventRouting.decision(
            forKeyCode: keyCode,
            flags: event.flags,
            context: currentContext()
        )

        guard let decision else {
            return Unmanaged.passUnretained(event)
        }

        // 只有命中规则时才拦截原事件；派发成功后返回 nil，让目标应用只收到转换后的事件。
        let result = actionDispatcher.dispatch(decision.output)

        if result.success {
            let appName = currentState().currentApp?.name ?? decision.ruleName
            Task { @MainActor [diagnostics] in
                diagnostics.recordHandledEvent(
                    HandledEventRecord(
                        timestamp: .now,
                        appName: appName,
                        bundleId: decision.bundleId,
                        trigger: decision.trigger,
                        output: decision.output,
                        ruleName: decision.ruleName
                    )
                )
            }

            return nil
        }

        Task { @MainActor [diagnostics] in
            diagnostics.recordError(result.message ?? "Failed to dispatch key event.")
        }

        return Unmanaged.passUnretained(event)
    }

    private func currentContext() -> EventRoutingContext {
        withStateLock { runtimeState in
            EventRoutingContext(
                settings: runtimeState.settings,
                currentApp: runtimeState.currentApp,
                rules: runtimeState.rules
            )
        }
    }

    private func currentState() -> RuntimeState {
        withStateLock { $0 }
    }

    private func reportListenerStatus(_ status: ListenerStatus) {
        Task { @MainActor [diagnostics] in
            diagnostics.updateListenerStatus(status)
        }
    }

    private func withStateLock<T>(_ body: (inout RuntimeState) -> T) -> T {
        stateLock.lock()
        defer { stateLock.unlock() }
        return body(&state)
    }
}
