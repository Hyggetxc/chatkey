import SwiftUI

@main
struct ChatKeyApp: App {
    private let container: AppContainer

    @StateObject private var permissionManager: PermissionManager
    @StateObject private var settingsStore: SettingsStore
    @StateObject private var ruleStore: RuleStore
    @StateObject private var updateManager: UpdateManager
    @StateObject private var diagnosticsCenter: DiagnosticsCenter

    init() {
        let container = AppContainer()
        self.container = container
        _permissionManager = StateObject(wrappedValue: container.permissionManager)
        _settingsStore = StateObject(wrappedValue: container.settingsStore)
        _ruleStore = StateObject(wrappedValue: container.ruleStore)
        _updateManager = StateObject(wrappedValue: container.updateManager)
        _diagnosticsCenter = StateObject(wrappedValue: container.diagnosticsCenter)
        container.start()
    }

    private var visualStatus: AppVisualStatus {
        AppVisualStatus.make(
            isEnabled: settingsStore.settings.isEnabled,
            isPermissionTrusted: permissionManager.isTrusted
        )
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(
                permissionManager: permissionManager,
                settingsStore: settingsStore,
                updateManager: updateManager,
                diagnosticsCenter: diagnosticsCenter
            )
            .frame(minWidth: 420)
        } label: {
            MenuBarStatusIcon(status: visualStatus)
                .help(menuBarStatusHelpText)
        }

        Settings {
            SettingsRootView(
                permissionManager: permissionManager,
                settingsStore: settingsStore,
                ruleStore: ruleStore,
                updateManager: updateManager,
                diagnosticsCenter: diagnosticsCenter
            )
            .frame(minWidth: 980, minHeight: 720)
        }
    }

    private var menuBarStatusHelpText: String {
        switch visualStatus {
        case .ready:
            return "\(BrandIdentity.displayName) · \(AppStrings.text(.enabled, language: settingsStore.settings.language))"
        case .paused:
            return "\(BrandIdentity.displayName) · \(AppStrings.text(.paused, language: settingsStore.settings.language))"
        case .permissionMissing:
            return "\(BrandIdentity.displayName) · \(AppStrings.text(.permissionsMissing, language: settingsStore.settings.language))"
        }
    }
}
