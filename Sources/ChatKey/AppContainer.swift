import Combine
import Foundation

@MainActor
final class AppContainer {
    let permissionManager: PermissionManager
    let frontmostAppMonitor: FrontmostAppMonitor
    let settingsStore: SettingsStore
    let ruleStore: RuleStore
    let updateManager: UpdateManager
    let diagnosticsCenter: DiagnosticsCenter

    private let eventTapService: EventTapService
    private var cancellables: Set<AnyCancellable> = []

    init() {
        permissionManager = PermissionManager()
        frontmostAppMonitor = FrontmostAppMonitor()
        settingsStore = SettingsStore()
        ruleStore = RuleStore()
        updateManager = UpdateManager(
            configuration: UpdateConfiguration.resolved(
                defaultOwner: "Hyggetxc",
                defaultRepository: "chatkey"
            )
        )
        diagnosticsCenter = DiagnosticsCenter()
        eventTapService = EventTapService(
            actionDispatcher: ActionDispatcher(),
            diagnostics: diagnosticsCenter
        )

        bindRuntimeState()
    }

    func start() {
        updateManager.scheduleStartupCheck(using: settingsStore)
        eventTapService.startIfNeeded()
    }

    // 所有会影响按键重映射结果的状态，都先在这里同步到事件监听层。
    // 这样 EventTap 回调不需要直接依赖 SwiftUI 或 @MainActor 对象，运行时更稳。
    private func bindRuntimeState() {
        eventTapService.updatePermissionTrusted(permissionManager.isTrusted)
        eventTapService.updateSettings(settingsStore.settings)
        eventTapService.updateRules(ruleStore.rules)
        eventTapService.updateCurrentApp(frontmostAppMonitor.currentApp)

        permissionManager.$authorizationStatus
            .sink { [weak self] status in
                self?.eventTapService.updatePermissionTrusted(status == .trusted)
            }
            .store(in: &cancellables)

        settingsStore.$settings
            .sink { [weak self] settings in
                self?.eventTapService.updateSettings(settings)
            }
            .store(in: &cancellables)

        ruleStore.$rules
            .sink { [weak self] rules in
                self?.eventTapService.updateRules(rules)
            }
            .store(in: &cancellables)

        frontmostAppMonitor.$currentApp
            .sink { [weak self] currentApp in
                self?.eventTapService.updateCurrentApp(currentApp)
            }
            .store(in: &cancellables)
    }
}
