import SwiftUI

struct RulesSettingsTabView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var ruleStore: RuleStore

    @StateObject private var installedAppsCatalog = InstalledAppsCatalogStore()
    @State private var selectedRuleID: UUID?
    @State private var selectedCatalogBundleID: String?
    @State private var appSearchText = ""

    private var language: AppLanguage {
        settingsStore.settings.language
    }

    private var filteredInstalledApps: [AppDescriptor] {
        let query = appSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return installedAppsCatalog.apps
        }

        return installedAppsCatalog.apps.filter { app in
            app.name.localizedCaseInsensitiveContains(query)
                || app.bundleId.localizedCaseInsensitiveContains(query)
        }
    }

    private var selectedCatalogApp: AppDescriptor? {
        filteredInstalledApps.first(where: { $0.bundleId == selectedCatalogBundleID })
            ?? installedAppsCatalog.apps.first(where: { $0.bundleId == selectedCatalogBundleID })
    }

    private var selectedCatalogRule: AppRule? {
        guard let selectedCatalogApp else {
            return nil
        }

        return ruleStore.rule(forBundleID: selectedCatalogApp.bundleId)
    }

    private var selectedEditorRuleID: UUID? {
        guard let selectedCatalogBundleID else {
            return selectedRuleID
        }

        return ruleStore.rule(forBundleID: selectedCatalogBundleID)?.id
    }

    var body: some View {
        HStack(alignment: .top, spacing: SettingsMetrics.pageSpacing) {
            sidebarColumn
                .frame(width: 360)

            detailColumn
        }
        .frame(maxWidth: 1120, alignment: .topLeading)
        .onAppear {
            if selectedRuleID == nil {
                selectedRuleID = ruleStore.rules.first?.id
            }

            if selectedCatalogBundleID == nil {
                selectedCatalogBundleID = installedAppsCatalog.apps.first?.bundleId
            }
        }
        .onChange(of: ruleStore.rules) { _, newRules in
            if let selectedRuleID, !newRules.contains(where: { $0.id == selectedRuleID }) {
                self.selectedRuleID = newRules.first?.id
            }
        }
        .onChange(of: installedAppsCatalog.apps) { _, newApps in
            guard let firstApp = newApps.first else {
                selectedCatalogBundleID = nil
                return
            }

            guard let selectedCatalogBundleID else {
                self.selectedCatalogBundleID = firstApp.bundleId
                return
            }

            if !newApps.contains(where: { $0.bundleId == selectedCatalogBundleID }) {
                self.selectedCatalogBundleID = firstApp.bundleId
            }
        }
        .onChange(of: appSearchText) { _, _ in
            guard
                let selectedCatalogBundleID,
                !filteredInstalledApps.contains(where: { $0.bundleId == selectedCatalogBundleID })
            else {
                return
            }

            self.selectedCatalogBundleID = filteredInstalledApps.first?.bundleId
        }
    }

    private var sidebarColumn: some View {
        VStack(alignment: .leading, spacing: SettingsMetrics.pageSpacing) {
            CardSurface {
                VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                    SectionHeaderView(
                        title: AppStrings.text(.installedApplications, language: language),
                        subtitle: "\(AppStrings.text(.installedApplicationsSubtitle, language: language)) · \(filteredInstalledApps.count) \(AppStrings.text(.resultsSuffix, language: language))"
                    )

                    TextField(
                        AppStrings.text(.appSearchPlaceholder, language: language),
                        text: $appSearchText
                    )
                    .textFieldStyle(.roundedBorder)

                    HStack(spacing: 10) {
                        Button(primaryActionTitle) {
                            guard let selectedCatalogApp else {
                                return
                            }

                            selectedRuleID = ruleStore.ensureRule(for: selectedCatalogApp)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedCatalogApp == nil)

                        Button(AppStrings.text(.refreshInstalledApps, language: language)) {
                            installedAppsCatalog.reload()
                        }
                        .buttonStyle(.bordered)
                        .disabled(installedAppsCatalog.loadState == .loading)

                        if installedAppsCatalog.loadState == .loading {
                            ProgressView()
                                .controlSize(.small)
                        }

                        Spacer(minLength: 0)
                    }

                    appList
                }
            }

            CardSurface {
                VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                    SectionHeaderView(
                        title: AppStrings.text(.rules, language: language),
                        subtitle: "\(AppStrings.text(.configuredRulesSubtitle, language: language)) · \(ruleStore.rules.count) \(AppStrings.text(.rulesSuffix, language: language))"
                    )

                    ruleList
                }
            }
        }
    }

    private var detailColumn: some View {
        Group {
            if let selectedEditorRuleID {
                RuleEditorView(
                    settingsStore: settingsStore,
                    ruleStore: ruleStore,
                    ruleID: selectedEditorRuleID
                )
            } else if let selectedCatalogApp {
                CardSurface(padding: 28) {
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeaderView(
                            title: selectedCatalogApp.name,
                            subtitle: AppStrings.text(.selectedAppNeedsRule, language: language),
                            systemImage: "keyboard.badge.ellipsis"
                        )
                        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)

                        HStack {
                            Spacer(minLength: 0)

                            Button(AppStrings.text(.createRuleForSelectedApp, language: language)) {
                                selectedRuleID = ruleStore.ensureRule(for: selectedCatalogApp)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                CardSurface(padding: 28) {
                    ContentUnavailableView(
                        AppStrings.text(.noRuleSelected, language: language),
                        systemImage: "keyboard"
                    )
                    .frame(maxWidth: .infinity, minHeight: 360)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .id(selectedCatalogBundleID ?? selectedRuleID?.uuidString ?? "rule-detail-empty")
    }

    @ViewBuilder
    private var appList: some View {
        if filteredInstalledApps.isEmpty, installedAppsCatalog.loadState != .loading {
            ContentUnavailableView(
                AppStrings.text(.noInstalledAppsFound, language: language),
                systemImage: "magnifyingglass"
            )
            .frame(maxWidth: .infinity, minHeight: 180)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredInstalledApps) { app in
                        let isSelected = selectedCatalogBundleID == app.bundleId
                        Button {
                            selectedCatalogBundleID = app.bundleId
                            selectedRuleID = ruleStore.rule(forBundleID: app.bundleId)?.id
                        } label: {
                            SidebarRowView(
                                title: app.name,
                                subtitle: app.bundleId,
                                isSelected: isSelected,
                                tint: .accentColor,
                                leadingIcon: "app",
                                trailingLabel: ruleStore.rule(forBundleID: app.bundleId) != nil ? AppStrings.text(.configuredTag, language: language) : nil
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }

    @ViewBuilder
    private var ruleList: some View {
        if ruleStore.rules.isEmpty {
            ContentUnavailableView(
                AppStrings.text(.noConfiguredRules, language: language),
                systemImage: "keyboard"
            )
            .frame(maxWidth: .infinity, minHeight: 180)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(ruleStore.rules) { rule in
                        let isSelected = selectedRuleID == rule.id
                        Button {
                            selectedRuleID = rule.id
                            selectedCatalogBundleID = rule.bundleId
                        } label: {
                            SidebarRowView(
                                title: rule.appName,
                                subtitle: rule.bundleId,
                                isSelected: isSelected,
                                tint: .accentColor,
                                leadingIcon: "keyboard",
                                trailingLabel: rule.isEnabled ? AppStrings.text(.enabled, language: language) : AppStrings.text(.paused, language: language)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 180)
        }
    }

    private var primaryActionTitle: String {
        if selectedCatalogRule != nil {
            return AppStrings.text(.openSelectedAppRule, language: language)
        }

        return AppStrings.text(.createRuleForSelectedApp, language: language)
    }
}
