import AppKit
import SwiftUI

struct GeneralSettingsTabView: View {
    @ObservedObject var permissionManager: PermissionManager
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var updateManager: UpdateManager
    @ObservedObject var diagnosticsCenter: DiagnosticsCenter

    private var language: AppLanguage {
        settingsStore.settings.language
    }

    private var visualStatus: AppVisualStatus {
        AppVisualStatus.make(
            isEnabled: settingsStore.settings.isEnabled,
            isPermissionTrusted: permissionManager.isTrusted
        )
    }

    private var statusPresentation: GeneralStatusPresentation {
        switch visualStatus {
        case .permissionMissing:
            return GeneralStatusPresentation(
                title: AppStrings.text(.statusPermissionMissingTitle, language: language),
                message: AppStrings.text(.statusPermissionMissingMessage, language: language),
                iconTint: .red,
                iconBackground: Color.red.opacity(0.12),
                actionTitle: AppStrings.text(.openSystemSettings, language: language)
            )
        case .paused:
            return GeneralStatusPresentation(
                title: AppStrings.text(.statusPausedTitle, language: language),
                message: AppStrings.text(.statusPausedMessage, language: language),
                iconTint: .orange,
                iconBackground: Color.orange.opacity(0.14),
                actionTitle: nil
            )
        case .ready:
            return GeneralStatusPresentation(
                title: AppStrings.text(.statusReadyTitle, language: language),
                message: AppStrings.text(.statusReadyMessage, language: language),
                iconTint: .green,
                iconBackground: Color.green.opacity(0.14),
                actionTitle: nil
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsMetrics.pageSpacing) {
            statusPanel
            preferencePanel
            updatePanel
            diagnosticsPanel
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            permissionManager.refresh()
        }
    }

    private var statusPanel: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                SectionHeaderView(
                    title: AppStrings.text(.statusOverview, language: language),
                    subtitle: statusPresentation.title
                )

                SettingsFieldRow(
                    title: statusPresentation.title,
                    subtitle: statusPresentation.message
                ) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(statusPresentation.iconBackground)
                                .frame(width: 36, height: 36)

                            MenuBarStatusIcon(status: visualStatus)
                                .frame(width: 22, height: 18)
                        }

                        if let actionTitle = statusPresentation.actionTitle {
                            Button(actionTitle) {
                                openAccessibilitySettings()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
    }

    private var preferencePanel: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                SectionHeaderView(
                    title: AppStrings.text(.preferences, language: language),
                    subtitle: AppStrings.text(.generalPreferencesSubtitle, language: language)
                )

                SettingsFieldRow(title: AppStrings.text(.appWideToggle, language: language)) {
                    Toggle("", isOn: Binding(
                        get: { settingsStore.settings.isEnabled },
                        set: { settingsStore.setAppEnabled($0) }
                    ))
                    .labelsHidden()
                }

                SettingsFieldRow(title: AppStrings.text(.language, language: language)) {
                    Picker(
                        AppStrings.text(.language, language: language),
                        selection: Binding(
                            get: { settingsStore.settings.language },
                            set: { settingsStore.setLanguage($0) }
                        )
                    ) {
                        Text(AppStrings.text(.followSystem, language: language)).tag(AppLanguage.system)
                        Text(AppStrings.text(.simplifiedChinese, language: language)).tag(AppLanguage.zhHans)
                        Text(AppStrings.text(.english, language: language)).tag(AppLanguage.en)
                    }
                    .labelsHidden()
                    .frame(width: 200)
                }
            }
        }
    }

    private var updatePanel: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                SectionHeaderView(
                    title: AppStrings.text(.updates, language: language),
                    subtitle: AppStrings.text(.generalUpdatesSubtitle, language: language)
                )

                SettingsFieldRow(title: AppStrings.text(.autoCheckUpdates, language: language)) {
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { settingsStore.settings.autoCheckForUpdates },
                            set: { settingsStore.setAutoCheckForUpdates($0) }
                        )
                    )
                    .labelsHidden()
                }

                statusRow(
                    title: AppStrings.text(.currentVersion, language: language),
                    value: updateManager.currentVersion,
                    tint: .primary
                )

                statusRow(
                    title: AppStrings.text(.latestStatus, language: language),
                    value: updateStatusText,
                    tint: .secondary
                )

                HStack(spacing: 10) {
                    Spacer(minLength: 0)

                    Button(AppStrings.text(.checkForUpdates, language: language)) {
                        Task {
                            await updateManager.checkForUpdates(using: settingsStore)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(minWidth: SettingsMetrics.buttonMinWidth)

                    Button(AppStrings.text(.openReleasesPage, language: language)) {
                        updateManager.openReleasesPage()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(!canOpenReleasesPage)
                    .frame(minWidth: SettingsMetrics.buttonMinWidth)
                }
            }
        }
    }

    private var diagnosticsPanel: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                SectionHeaderView(
                    title: AppStrings.text(.diagnostics, language: language),
                    subtitle: AppStrings.text(.generalDiagnosticsSubtitle, language: language)
                )

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: diagnosticsCenter.lastErrorMessage == nil ? "exclamationmark.triangle" : "xmark.octagon.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(diagnosticsCenter.lastErrorMessage == nil ? .orange : .red)

                    Text(diagnosticsMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var canOpenReleasesPage: Bool {
        if case .repositoryNotConfigured = updateManager.status {
            return false
        }
        return true
    }

    private var diagnosticsMessage: String {
        diagnosticsCenter.lastErrorMessage ?? AppStrings.text(.generalNoDiagnosticsMessage, language: language)
    }

    private var updateStatusText: String {
        switch updateManager.status {
        case .idle:
            return "—"
        case .checking:
            return AppStrings.text(.checkingUpdates, language: language)
        case .upToDate:
            return AppStrings.text(.upToDate, language: language)
        case let .updateAvailable(release):
            return "\(AppStrings.text(.updateAvailable, language: language)): \(release.tagName)"
        case .repositoryNotConfigured:
            return AppStrings.text(.updateRepositoryNotConfigured, language: language)
        case let .failed(message):
            return "\(AppStrings.text(.updateCheckFailed, language: language)): \(message)"
        }
    }

    @ViewBuilder
    private func statusRow(title: String, value: String, tint: Color) -> some View {
        SettingsFieldRow(title: title, alignment: .top) {
            Text(value)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(maxWidth: 360, alignment: .trailing)
        }
    }

    private func openAccessibilitySettings() {
        if
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"),
            NSWorkspace.shared.open(url)
        {
            return
        }

        permissionManager.requestPermission()
    }
}

private struct GeneralStatusPresentation {
    let title: String
    let message: String
    let iconTint: Color
    let iconBackground: Color
    let actionTitle: String?
}
