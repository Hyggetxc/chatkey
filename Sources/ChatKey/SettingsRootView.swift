import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var permissionManager: PermissionManager
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var ruleStore: RuleStore
    @ObservedObject var updateManager: UpdateManager
    @ObservedObject var diagnosticsCenter: DiagnosticsCenter

    @StateObject private var installedAppsCatalog = InstalledAppsCatalogStore()
    @State private var selectedSection: SettingsSection = .rules

    private var language: AppLanguage {
        settingsStore.settings.language
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    SettingsHeroHeader(
                        title: AppStrings.text(.settingsWindowTitle, language: language),
                        subtitle: BrandIdentity.displayName,
                        systemImage: "keyboard"
                    )

                    Picker("", selection: $selectedSection) {
                        ForEach(SettingsSection.allCases) { section in
                            Text(section.title(language: language)).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }

                selectedContent
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: 1180, alignment: .topLeading)
            .padding(24)
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
                ruleStore: ruleStore,
                installedAppsCatalog: installedAppsCatalog
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
