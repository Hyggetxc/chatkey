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

            StatusPill(
                title: statusPresentation.title,
                tint: statusPresentation.iconTint,
                systemImage: statusPillSymbolName
            )
        }
        .padding(.horizontal, 4)
    }

    private var enableCard: some View {
        CardSurface(padding: 16, cornerRadius: 18) {
            HStack(alignment: .center, spacing: 14) {
                statusGlyph(background: Color.accentColor.opacity(0.12), tint: .accentColor, symbol: "checkmark")

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

                    if !statusPresentation.showsOpenSettingsButton {
                        StatusPill(
                            title: statusPresentation.subtitle,
                            tint: statusPresentation.iconTint,
                            systemImage: nil
                        )
                    }
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
            VStack(alignment: .leading, spacing: 10) {
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

    private var statusPillSymbolName: String? {
        switch visualStatus {
        case .permissionMissing:
            return "exclamationmark.triangle.fill"
        case .paused:
            return "pause.fill"
        case .ready:
            return "checkmark"
        }
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
        let image = NSApp.applicationIconImage ?? NSImage(named: NSImage.applicationIconName) ?? NSImage(size: NSSize(width: 1, height: 1))

        Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 46, height: 46)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            )
    }
}
