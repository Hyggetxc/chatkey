import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var permissionManager: PermissionManager
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var ruleStore: RuleStore
    @ObservedObject var updateManager: UpdateManager
    @ObservedObject var diagnosticsCenter: DiagnosticsCenter

    @State private var selectedSection: SettingsSection = .general

    private var language: AppLanguage {
        settingsStore.settings.language
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Picker("", selection: $selectedSection) {
                    ForEach(SettingsSection.allCases) { section in
                        Text(section.title(language: language)).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
                .frame(maxWidth: .infinity)

                selectedContent
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: 1120, alignment: .topLeading)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(SettingsPageBackground())
        .background(
            WindowTitleConfigurator(title: AppStrings.text(.settingsWindowTitle, language: language))
        )
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .general:
            GeneralSettingsTabView(
                permissionManager: permissionManager,
                settingsStore: settingsStore,
                updateManager: updateManager,
                diagnosticsCenter: diagnosticsCenter
            )
        case .rules:
            RulesSettingsTabView(
                settingsStore: settingsStore,
                ruleStore: ruleStore
            )
        }
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case rules

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .general:
            return AppStrings.text(.general, language: language)
        case .rules:
            return AppStrings.text(.rules, language: language)
        }
    }
}
