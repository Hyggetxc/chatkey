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
        VStack(alignment: .leading, spacing: 12) {
            header
            enableCard
            runtimeStatusCard
            actionCard
        }
        .padding(14)
        .frame(width: 420)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            permissionManager.refresh()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            BrandAppIconBadge()

            VStack(alignment: .leading, spacing: 4) {
                Text(BrandIdentity.displayName)
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(AppStrings.text(.menuPopoverSubtitle, language: language))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }

    private var enableCard: some View {
        CardSurface(padding: 16, cornerRadius: 18) {
            HStack(alignment: .center, spacing: 14) {
                statusGlyph(background: Color.accentColor.opacity(0.12), tint: .accentColor, symbol: enableGlyphSymbol)

                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.text(.appWideToggle, language: language))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(AppStrings.text(.menuToggleHint, language: language))
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Toggle("", isOn: Binding(
                    get: { settingsStore.settings.isEnabled },
                    set: { settingsStore.setAppEnabled($0) }
                ))
                .labelsHidden()
                .toggleStyle(.switch)
            }
        }
    }

    private var runtimeStatusCard: some View {
        CardSurface(padding: 16, cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    statusGlyph(background: statusPresentation.iconBackground, tint: statusPresentation.iconTint, symbol: statusPresentation.icon)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusPresentation.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text(statusSubtitleText)
                            .font(.system(size: 12.5, weight: .regular))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if statusPresentation.showsOpenSettingsButton {
                    Button(AppStrings.text(.openSystemSettings, language: language)) {
                        openAccessibilitySettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var actionCard: some View {
        CardSurface(padding: 14, cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    Task {
                        await updateManager.checkForUpdates(using: settingsStore)
                    }
                } label: {
                    menuActionLabel(AppStrings.text(.checkForUpdates, language: language))
                }
                .buttonStyle(.plain)

                Divider()

                SettingsLink {
                    menuActionLabel(AppStrings.text(.openSettings, language: language))
                }
                .buttonStyle(.plain)

                Divider()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    menuActionLabel(AppStrings.text(.quit, language: language))
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
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

    private var enableGlyphSymbol: String {
        settingsStore.settings.isEnabled ? "checkmark" : "pause.fill"
    }

    @ViewBuilder
    private func statusGlyph(background: Color, tint: Color, symbol: String) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(background)
            .frame(width: 34, height: 34)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
            }
    }

    private func menuActionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
            .contentShape(Rectangle())
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
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
            Image(systemName: "keyboard")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(width: 42, height: 42)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
