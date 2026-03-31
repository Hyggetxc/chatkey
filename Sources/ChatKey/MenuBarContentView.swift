import AppKit
import SwiftUI

struct MenuBarContentView: View {
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

    private var statusPresentation: MenuStatusPresentation {
        switch visualStatus {
        case .permissionMissing:
            return MenuStatusPresentation(
                icon: "lock.fill",
                iconTint: .red,
                iconBackground: Color.red.opacity(0.12),
                title: AppStrings.text(.permissionsMissing, language: language),
                subtitle: AppStrings.text(.permissionGrantHelp, language: language),
                showsOpenSettingsButton: true
            )
        case .paused:
            return MenuStatusPresentation(
                icon: "pause.circle.fill",
                iconTint: .orange,
                iconBackground: Color.orange.opacity(0.14),
                title: AppStrings.text(.paused, language: language),
                subtitle: AppStrings.text(.listener, language: language),
                showsOpenSettingsButton: false
            )
        case .ready:
            return MenuStatusPresentation(
                icon: "checkmark.circle.fill",
                iconTint: .green,
                iconBackground: Color.green.opacity(0.14),
                title: AppStrings.text(.enabled, language: language),
                subtitle: AppStrings.text(.listenerActive, language: language),
                showsOpenSettingsButton: false
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header

            enableCard

            runtimeStatusCard

            actionCard
        }
        .padding(12)
        .frame(width: 420)
        .onAppear {
            permissionManager.refresh()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(statusPresentation.iconBackground)
                    .frame(width: 28, height: 28)

                Image(systemName: statusPresentation.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(statusPresentation.iconTint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(BrandIdentity.displayName)
                    .font(.system(size: 26, weight: .semibold))
                Text(AppStrings.text(.menuPopoverSubtitle, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }

    private var enableCard: some View {
        CardSurface(padding: 14, cornerRadius: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .frame(width: 28, height: 28)

                    MenuBarStatusIcon(status: visualStatus)
                        .frame(width: 20, height: 16)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(AppStrings.text(.appWideToggle, language: language))
                        .font(.system(size: 14, weight: .semibold))
                    Text(AppStrings.text(.menuToggleHint, language: language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Toggle("", isOn: Binding(
                    get: { settingsStore.settings.isEnabled },
                    set: { settingsStore.setAppEnabled($0) }
                ))
                .labelsHidden()
            }
        }
    }

    private var runtimeStatusCard: some View {
        CardSurface(padding: 14, cornerRadius: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(statusPresentation.iconBackground)
                        .frame(width: 28, height: 28)

                    Image(systemName: statusPresentation.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(statusPresentation.iconTint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusPresentation.title)
                        .font(.system(size: 13, weight: .semibold))
                    Text(statusSubtitleText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if statusPresentation.showsOpenSettingsButton {
                    Button(AppStrings.text(.openSystemSettings, language: language)) {
                        openAccessibilitySettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }

    private var actionCard: some View {
        CardSurface(padding: 12, cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Button(AppStrings.text(.checkForUpdates, language: language)) {
                    Task {
                        await updateManager.checkForUpdates(using: settingsStore)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                SettingsLink {
                    Text(AppStrings.text(.openSettings, language: language))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(AppStrings.text(.quit, language: language)) {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var statusSubtitleText: String {
        switch diagnosticsCenter.listenerStatus {
        case .active:
            return statusPresentation.subtitle
        case .inactive(.disabledByUser):
            return AppStrings.text(.paused, language: language)
        case .inactive(.missingPermission):
            return AppStrings.text(.permissionRequired, language: language)
        case let .failed(message):
            return message
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

private struct MenuStatusPresentation {
    let icon: String
    let iconTint: Color
    let iconBackground: Color
    let title: String
    let subtitle: String
    let showsOpenSettingsButton: Bool
}
