import SwiftUI

struct RulesSettingsTabView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var ruleStore: RuleStore
    @ObservedObject var installedAppsCatalog: InstalledAppsCatalogStore

    @State private var selectedRuleID: UUID?
    @State private var selectedCatalogBundleID: String?
    @State private var appSearchText = ""
    @State private var ruleFilter: RuleListFilter = .all

    private var language: AppLanguage {
        settingsStore.settings.language
    }

    private var filteredInstalledApps: [AppDescriptor] {
        let query = appSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchedApps: [AppDescriptor]

        if query.isEmpty {
            searchedApps = installedAppsCatalog.apps
        } else {
            searchedApps = installedAppsCatalog.apps.filter { app in
                app.name.localizedCaseInsensitiveContains(query)
                    || app.bundleId.localizedCaseInsensitiveContains(query)
            }
        }

        return searchedApps.filter { app in
            switch ruleFilter {
            case .all:
                return true
            case .configured:
                return ruleStore.rule(forBundleID: app.bundleId) != nil
            case .unconfigured:
                return ruleStore.rule(forBundleID: app.bundleId) == nil
            }
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
        HStack(alignment: .top, spacing: 18) {
            sidebarColumn
                .frame(width: 352)

            detailColumn
        }
        .frame(maxWidth: 1180, alignment: .topLeading)
        .onAppear {
            initializeSelectionIfNeeded()
        }
        .onChange(of: ruleStore.rules) { _, newRules in
            if let selectedRuleID, !newRules.contains(where: { $0.id == selectedRuleID }) {
                self.selectedRuleID = newRules.first?.id
            }
            ensureSelectionVisibleInFilteredApps()
        }
        .onChange(of: installedAppsCatalog.apps) { _, newApps in
            guard let firstApp = newApps.first else {
                selectedCatalogBundleID = nil
                return
            }

            guard let selectedCatalogBundleID else {
                initializeSelectionIfNeeded()
                if self.selectedCatalogBundleID == nil {
                    self.selectedCatalogBundleID = firstApp.bundleId
                }
                return
            }

            if !newApps.contains(where: { $0.bundleId == selectedCatalogBundleID }) {
                self.selectedCatalogBundleID = firstApp.bundleId
            }
        }
        .onChange(of: appSearchText) { _, _ in
            ensureSelectionVisibleInFilteredApps()
        }
        .onChange(of: ruleFilter) { _, _ in
            ensureSelectionVisibleInFilteredApps()
        }
    }

    private func initializeSelectionIfNeeded() {
        if
            selectedCatalogBundleID == nil,
            let firstConfiguredRule = ruleStore.rules.first,
            installedAppsCatalog.apps.contains(where: { $0.bundleId == firstConfiguredRule.bundleId })
        {
            selectedRuleID = firstConfiguredRule.id
            selectedCatalogBundleID = firstConfiguredRule.bundleId
            return
        }

        if selectedCatalogBundleID == nil {
            selectedCatalogBundleID = installedAppsCatalog.apps.first?.bundleId
        }

        if selectedRuleID == nil {
            selectedRuleID = selectedCatalogBundleID.flatMap { ruleStore.rule(forBundleID: $0)?.id }
                ?? ruleStore.rules.first?.id
        }
    }

    private func ensureSelectionVisibleInFilteredApps() {
        guard
            let selectedCatalogBundleID,
            !filteredInstalledApps.contains(where: { $0.bundleId == selectedCatalogBundleID })
        else {
            return
        }

        self.selectedCatalogBundleID = filteredInstalledApps.first?.bundleId
        selectedRuleID = filteredInstalledApps.first.flatMap { ruleStore.rule(forBundleID: $0.bundleId)?.id }
    }

    private var filterPicker: some View {
        Picker("", selection: $ruleFilter) {
            ForEach(RuleListFilter.allCases) { filter in
                Text(filter.title(language: language)).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var sidebarColumn: some View {
        LiquidPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppStrings.text(.rules, language: language))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))

                        Text("\(filteredInstalledApps.count) \(AppStrings.text(.resultsSuffix, language: language)) · \(ruleStore.rules.count) \(AppStrings.text(.rulesSuffix, language: language))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)

                    if installedAppsCatalog.loadState == .loading {
                        ProgressView()
                            .controlSize(.small)
                    }

                    Button {
                        installedAppsCatalog.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(LiquidIconButtonStyle())
                    .disabled(installedAppsCatalog.loadState == .loading)
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        AppStrings.text(.appSearchPlaceholder, language: language),
                        text: $appSearchText
                    )
                    .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(SettingsTheme.cardTintStrong.opacity(0.50))
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(SettingsTheme.hairline, lineWidth: 1)
                }

                filterPicker

                appList

                HStack(spacing: 10) {
                    Button {
                        guard let selectedCatalogApp else {
                            return
                        }

                        selectedRuleID = ruleStore.ensureRule(for: selectedCatalogApp)
                    } label: {
                        Label(primaryActionTitle, systemImage: selectedCatalogRule == nil ? "plus" : "keyboard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LiquidButtonStyle(kind: .primary))
                    .disabled(selectedCatalogApp == nil)
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
                LiquidPanel {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: "keyboard.badge.ellipsis")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(SettingsTheme.primary)
                                .frame(width: 48, height: 48)
                                .background(SettingsTheme.cardTintStrong, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(SettingsTheme.hairline, lineWidth: 1)
                                }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(selectedCatalogApp.name)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))

                                Text(selectedCatalogApp.bundleId)
                                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.secondary)

                                Text(AppStrings.text(.selectedAppNeedsRule, language: language))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }

                            Spacer(minLength: 0)
                        }

                        Divider()
                            .opacity(0.55)

                        Button {
                            selectedRuleID = ruleStore.ensureRule(for: selectedCatalogApp)
                        } label: {
                            Label(AppStrings.text(.createRuleForSelectedApp, language: language), systemImage: "plus")
                        }
                        .buttonStyle(LiquidButtonStyle(kind: .primary))
                    }
                    .frame(maxWidth: .infinity, minHeight: 320, alignment: .topLeading)
                }
            } else {
                LiquidPanel {
                    if installedAppsCatalog.loadState == .loading {
                        ProgressView()
                            .controlSize(.large)
                            .frame(maxWidth: .infinity, minHeight: 360)
                    } else {
                        ContentUnavailableView(
                            AppStrings.text(.noRuleSelected, language: language),
                            systemImage: "keyboard"
                        )
                        .frame(maxWidth: .infinity, minHeight: 360)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
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
                LazyVStack(spacing: 10) {
                    ForEach(filteredInstalledApps) { app in
                        let isSelected = selectedCatalogBundleID == app.bundleId
                        Button {
                            selectedCatalogBundleID = app.bundleId
                            selectedRuleID = ruleStore.rule(forBundleID: app.bundleId)?.id
                        } label: {
                            SourceListRowView(
                                title: app.name,
                                subtitle: app.bundleId,
                                isSelected: isSelected,
                                leadingIcon: "app",
                                trailingLabel: appStateLabel(for: app)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 460)
        }
    }

    private var primaryActionTitle: String {
        if selectedCatalogRule != nil {
            return AppStrings.text(.openSelectedAppRule, language: language)
        }

        return AppStrings.text(.createRuleForSelectedApp, language: language)
    }

    private func appStateLabel(for app: AppDescriptor) -> String {
        guard let rule = ruleStore.rule(forBundleID: app.bundleId) else {
            return AppStrings.text(.unconfiguredTag, language: language)
        }

        return rule.isEnabled ? AppStrings.text(.enabled, language: language) : AppStrings.text(.paused, language: language)
    }
}

private enum RuleListFilter: String, CaseIterable, Identifiable {
    case all
    case configured
    case unconfigured

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .all:
            return AppStrings.text(.allAppsFilter, language: language)
        case .configured:
            return AppStrings.text(.configuredTag, language: language)
        case .unconfigured:
            return AppStrings.text(.unconfiguredTag, language: language)
        }
    }
}
