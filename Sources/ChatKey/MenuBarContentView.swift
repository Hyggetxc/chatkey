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
                icon: "exclamationmark.triangle.fill",
                iconTint: .red,
                iconBackground: Color.red.opacity(0.12),
                title: AppStrings.text(.statusPermissionMissingTitle, language: language),
                subtitle: AppStrings.text(.statusPermissionMissingMessage, language: language),
                showsOpenSettingsButton: true
            )
        case .paused:
            return MenuStatusPresentation(
                icon: "pause.circle.fill",
                iconTint: .orange,
                iconBackground: Color.orange.opacity(0.14),
                title: AppStrings.text(.statusPausedTitle, language: language),
                subtitle: AppStrings.text(.statusPausedMessage, language: language),
                showsOpenSettingsButton: false
            )
        case .ready:
            return MenuStatusPresentation(
                icon: "checkmark.circle.fill",
                iconTint: .green,
                iconBackground: Color.green.opacity(0.14),
                title: AppStrings.text(.statusReadyTitle, language: language),
                subtitle: AppStrings.text(.statusReadyMessage, language: language),
                showsOpenSettingsButton: false
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            statusControl

            if statusPresentation.showsOpenSettingsButton {
                Button {
                    openAccessibilitySettings()
                } label: {
                    Label(AppStrings.text(.openSystemSettings, language: language), systemImage: "switch.2")
                        .font(.system(size: 13.5, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            actionRows
        }
        .padding(8)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                )
        )
        .padding(4)
        .onAppear {
            permissionManager.refresh()
        }
    }

    private var statusControl: some View {
        HStack(alignment: .center, spacing: 10) {
            BrandAppIconBadge(status: visualStatus)

            VStack(alignment: .leading, spacing: 2) {
                Text(BrandIdentity.displayName)
                    .font(.system(size: 15.5, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(statusPresentation.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: Binding(
                get: { settingsStore.settings.isEnabled },
                set: { settingsStore.setAppEnabled($0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)
        }
        .padding(.horizontal, 9)
        .frame(minHeight: 46)
        .background(
            Capsule(style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.52))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 2)
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
        )
        .help(statusSubtitleText)
    }

    private var actionRows: some View {
        VStack(spacing: 0) {
            Button {
                Task {
                    await updateManager.checkForUpdates(using: settingsStore)
                }
            } label: {
                MenuActionRow(
                    title: AppStrings.text(.checkForUpdates, language: language),
                    systemImage: "arrow.down.circle"
                )
            }
            .buttonStyle(.plain)

            MenuDivider()

            SettingsLink {
                MenuActionRow(
                    title: AppStrings.text(.openSettings, language: language),
                    systemImage: "gearshape"
                )
            }
            .buttonStyle(.plain)

            MenuDivider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                MenuActionRow(
                    title: AppStrings.text(.quit, language: language),
                    systemImage: "power"
                )
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    private var statusSubtitleText: String {
        switch diagnosticsCenter.listenerStatus {
        case .failed(let message):
            return message
        default:
            return statusPresentation.subtitle
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

private struct BrandAppIconBadge: View {
    let status: AppVisualStatus

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.8))

            Image(systemName: "keyboard")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)

            Circle()
                .fill(statusTint)
                .frame(width: 7, height: 7)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(4)
        }
        .frame(width: 30, height: 30)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.36), lineWidth: 1)
        )
    }

    private var statusTint: Color {
        switch status {
        case .permissionMissing:
            return .red
        case .paused:
            return .orange
        case .ready:
            return .green
        }
    }
}

private struct MenuDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 46)
            .padding(.trailing, 10)
    }
}
