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
                statusIcon: "exclamationmark.triangle.fill",
                actionTitle: AppStrings.text(.openSystemSettings, language: language)
            )
        case .paused:
            return GeneralStatusPresentation(
                title: AppStrings.text(.statusPausedTitle, language: language),
                message: AppStrings.text(.statusPausedMessage, language: language),
                iconTint: .orange,
                iconBackground: Color.orange.opacity(0.14),
                statusIcon: "pause.circle.fill",
                actionTitle: nil
            )
        case .ready:
            return GeneralStatusPresentation(
                title: AppStrings.text(.statusReadyTitle, language: language),
                message: AppStrings.text(.statusReadyMessage, language: language),
                iconTint: .green,
                iconBackground: Color.green.opacity(0.14),
                statusIcon: "checkmark.circle.fill",
                actionTitle: nil
            )
        }
    }

    var body: some View {
        LiquidPanel {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppStrings.text(.general, language: language))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))

                        Text(AppStrings.text(.generalPreferencesSubtitle, language: language))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)

                    StatusPill(
                        title: statusPresentation.title,
                        tint: statusPresentation.iconTint,
                        systemImage: statusPresentation.statusIcon
                    )
                }

                Divider()
                    .opacity(0.55)

                SettingsSectionLabel(AppStrings.text(.statusOverview, language: language))
                statusPanel

                SettingsSectionLabel(
                    AppStrings.text(.preferences, language: language),
                    subtitle: AppStrings.text(.generalPreferencesSubtitle, language: language)
                )
                controlsPanel

                SettingsSectionLabel(
                    AppStrings.text(.updates, language: language),
                    subtitle: AppStrings.text(.generalUpdatesSubtitle, language: language)
                )
                updatePanel

                SettingsSectionLabel(
                    AppStrings.text(.diagnostics, language: language),
                    subtitle: AppStrings.text(.generalDiagnosticsSubtitle, language: language)
                )
                diagnosticsPanel
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            permissionManager.refresh()
        }
    }

    private var statusPanel: some View {
        SettingsGroup {
            SettingsGroupRow(
                title: AppStrings.text(.statusOverview, language: language),
                subtitle: statusPresentation.message
            ) {
                HStack(spacing: 12) {
                    Spacer(minLength: 0)

                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(statusPresentation.iconBackground)
                            .frame(width: 36, height: 36)

                        MenuBarStatusIcon(status: visualStatus)
                            .frame(width: 23, height: 18)
                    }

                    Text(statusPresentation.title)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(statusPresentation.iconTint)

                    if let actionTitle = statusPresentation.actionTitle {
                        Button(actionTitle) {
                            openAccessibilitySettings()
                        }
                        .buttonStyle(LiquidButtonStyle(kind: .secondary))
                    }
                }
            }
        }
    }

    private var controlsPanel: some View {
        SettingsGroup {
            SettingsGroupRow(title: AppStrings.text(.appWideToggle, language: language)) {
                Toggle("", isOn: Binding(
                    get: { settingsStore.settings.isEnabled },
                    set: { settingsStore.setAppEnabled($0) }
                ))
                .labelsHidden()
            }

            SettingsDivider()

            SettingsGroupRow(title: AppStrings.text(.launchAtLogin, language: language)) {
                Toggle("", isOn: Binding(
                    get: { settingsStore.settings.launchAtLogin },
                    set: { settingsStore.setLaunchAtLogin($0) }
                ))
                .labelsHidden()
            }

            SettingsDivider()

            SettingsGroupRow(title: AppStrings.text(.language, language: language)) {
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

            SettingsDivider()

            SettingsGroupRow(title: AppStrings.text(.autoCheckUpdates, language: language)) {
                Toggle(
                    "",
                    isOn: Binding(
                        get: { settingsStore.settings.autoCheckForUpdates },
                        set: { settingsStore.setAutoCheckForUpdates($0) }
                    )
                )
                .labelsHidden()
            }
        }
    }

    private var updatePanel: some View {
        SettingsGroup {
            statusRow(
                title: AppStrings.text(.currentVersion, language: language),
                value: updateManager.currentVersion,
                tint: .primary
            )

            SettingsDivider()

            statusRow(
                title: AppStrings.text(.latestStatus, language: language),
                value: updateStatusText,
                tint: .secondary
            )

            SettingsDivider()

            HStack(spacing: 10) {
                Spacer(minLength: 0)

                Button(AppStrings.text(.checkForUpdates, language: language)) {
                    Task {
                        await updateManager.checkForUpdates(using: settingsStore)
                    }
                }
                .buttonStyle(LiquidButtonStyle(kind: .primary))
                .frame(minWidth: SettingsMetrics.buttonMinWidth)

                Button(AppStrings.text(.openReleasesPage, language: language)) {
                    updateManager.openReleasesPage()
                }
                .buttonStyle(LiquidButtonStyle(kind: .secondary))
                .disabled(!canOpenReleasesPage)
                .frame(minWidth: SettingsMetrics.buttonMinWidth)
            }
            .padding(.horizontal, SettingsMetrics.rowPadding)
            .padding(.vertical, 10)
        }
    }

    private var diagnosticsPanel: some View {
        SettingsGroup {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: diagnosticsCenter.lastErrorMessage == nil ? "exclamationmark.triangle" : "xmark.octagon.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(diagnosticsCenter.lastErrorMessage == nil ? .orange : .red)

                Text(diagnosticsMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(SettingsMetrics.rowPadding)
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
        SettingsGroupRow(title: title, alignment: .top) {
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
    let statusIcon: String
    let actionTitle: String?
}
