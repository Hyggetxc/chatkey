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
        VStack(alignment: .leading, spacing: 12) {
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
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(
                    title: AppStrings.text(.statusOverview, language: language),
                    subtitle: statusPresentation.title
                )

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(statusPresentation.iconBackground)
                            .frame(width: 28, height: 28)

                        MenuBarStatusIcon(status: visualStatus)
                            .frame(width: 20, height: 16)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusPresentation.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(statusPresentation.message)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(statusPresentation.iconTint)
                    }

                    Spacer(minLength: 0)

                    if let actionTitle = statusPresentation.actionTitle {
                        Button(actionTitle) {
                            openAccessibilitySettings()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var preferencePanel: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: AppStrings.text(.preferences, language: language),
                    subtitle: AppStrings.text(.generalPreferencesSubtitle, language: language)
                )

                LabeledContent(AppStrings.text(.appWideToggle, language: language)) {
                    Toggle("", isOn: Binding(
                        get: { settingsStore.settings.isEnabled },
                        set: { settingsStore.setAppEnabled($0) }
                    ))
                    .labelsHidden()
                }

                Divider()

                LabeledContent(AppStrings.text(.language, language: language)) {
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
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: AppStrings.text(.updates, language: language),
                    subtitle: AppStrings.text(.generalUpdatesSubtitle, language: language)
                )

                Toggle(
                    AppStrings.text(.autoCheckUpdates, language: language),
                    isOn: Binding(
                        get: { settingsStore.settings.autoCheckForUpdates },
                        set: { settingsStore.setAutoCheckForUpdates($0) }
                    )
                )

                Divider()

                statusRow(
                    title: AppStrings.text(.currentVersion, language: language),
                    value: updateManager.currentVersion,
                    tint: .primary
                )

                Divider()

                statusRow(
                    title: AppStrings.text(.latestStatus, language: language),
                    value: updateStatusText,
                    tint: .secondary
                )

                HStack(spacing: 10) {
                    Button(AppStrings.text(.checkForUpdates, language: language)) {
                        Task {
                            await updateManager.checkForUpdates(using: settingsStore)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(minWidth: 148)

                    Button(AppStrings.text(.openReleasesPage, language: language)) {
                        updateManager.openReleasesPage()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(!canOpenReleasesPage)
                    .frame(minWidth: 148)

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var diagnosticsPanel: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(
                    title: AppStrings.text(.diagnostics, language: language),
                    subtitle: AppStrings.text(.generalDiagnosticsSubtitle, language: language)
                )

                HStack(alignment: .top, spacing: 10) {
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
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Text(value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.semibold)
                .foregroundStyle(tint)
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
