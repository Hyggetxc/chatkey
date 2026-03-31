@preconcurrency import AppKit
@preconcurrency import ApplicationServices
import Combine
import Foundation

enum AccessibilityAuthorizationStatus: Equatable {
    case trusted
    case notTrusted
}

@MainActor
final class PermissionManager: ObservableObject {
    @Published private(set) var authorizationStatus: AccessibilityAuthorizationStatus = .notTrusted

    private var cancellables: Set<AnyCancellable> = []
    private var pendingPermissionPoll: AnyCancellable?

    init() {
        observePermissionRelevantLifecycle()
        refresh()
    }

    var isTrusted: Bool {
        authorizationStatus == .trusted
    }

    func refresh() {
        authorizationStatus = AXIsProcessTrusted() ? .trusted : .notTrusted
        updatePollingIfNeeded()
    }

    func requestPermission() {
        // 这里显式触发系统授权弹窗，避免用户去系统设置里自己找入口。
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        refresh()
    }

    private func observePermissionRelevantLifecycle() {
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    private func updatePollingIfNeeded() {
        guard authorizationStatus == .notTrusted else {
            pendingPermissionPoll = nil
            return
        }

        guard pendingPermissionPoll == nil else {
            return
        }

        // 用户通常会在系统设置里手动勾选辅助功能权限。
        // 在未授权阶段做短轮询，可以让状态在授权后自动恢复，不要求重启应用。
        pendingPermissionPoll = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }

                let nextStatus: AccessibilityAuthorizationStatus = AXIsProcessTrusted() ? .trusted : .notTrusted
                if self.authorizationStatus != nextStatus {
                    self.authorizationStatus = nextStatus
                }

                if nextStatus == .trusted {
                    self.pendingPermissionPoll = nil
                }
            }
    }
}
