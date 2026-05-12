import AppKit
import SwiftUI

enum SettingsMetrics {
    static let pageSpacing: CGFloat = 18
    static let sectionSpacing: CGFloat = 14
    static let cardPadding: CGFloat = 20
    static let rowPadding: CGFloat = 12
    static let compactRowPadding: CGFloat = 12
    static let cardCornerRadius: CGFloat = 24
    static let innerCornerRadius: CGFloat = 16
    static let rowCornerRadius: CGFloat = 12
    static let iconSize: CGFloat = 18
    static let badgeSize: CGFloat = 40
    static let labelColumnWidth: CGFloat = 154
    static let buttonMinWidth: CGFloat = 148
}

enum SettingsTheme {
    static var canvas: LinearGradient {
        LinearGradient(
            colors: [
                Color.adaptive(
                    light: NSColor(red: 0.96, green: 0.98, blue: 1.00, alpha: 1.00),
                    dark: NSColor(red: 0.05, green: 0.07, blue: 0.10, alpha: 1.00)
                ),
                Color.adaptive(
                    light: NSColor(red: 0.91, green: 0.95, blue: 0.99, alpha: 1.00),
                    dark: NSColor(red: 0.09, green: 0.13, blue: 0.19, alpha: 1.00)
                )
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let primary = Color(red: 0.04, green: 0.45, blue: 0.95)
    static let success = Color(red: 0.10, green: 0.62, blue: 0.42)
    static let warning = Color(red: 0.82, green: 0.48, blue: 0.08)
    static let danger = Color(red: 0.86, green: 0.19, blue: 0.24)

    static var cardTint: Color {
        Color.adaptive(
            light: NSColor.white.withAlphaComponent(0.56),
            dark: NSColor.white.withAlphaComponent(0.07)
        )
    }

    static var cardTintStrong: Color {
        Color.adaptive(
            light: NSColor.white.withAlphaComponent(0.66),
            dark: NSColor.white.withAlphaComponent(0.10)
        )
    }

    static var hairline: Color {
        Color.adaptive(
            light: NSColor.white.withAlphaComponent(0.62),
            dark: NSColor.white.withAlphaComponent(0.16)
        )
    }

    static var shadow: Color {
        Color.adaptive(
            light: NSColor.black.withAlphaComponent(0.06),
            dark: NSColor.black.withAlphaComponent(0.30)
        )
    }

    static var disabledFill: Color {
        Color.adaptive(
            light: NSColor.gray.withAlphaComponent(0.12),
            dark: NSColor.white.withAlphaComponent(0.08)
        )
    }
}

extension Color {
    static func adaptive(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .aqua])
            return match == .darkAqua ? dark : light
        })
    }
}

struct SettingsPageBackground: View {
    var body: some View {
        SettingsTheme.canvas
    }
}

struct LiquidPanel<Content: View>: View {
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: Content

    init(
        padding: CGFloat = SettingsMetrics.cardPadding,
        cornerRadius: CGFloat = SettingsMetrics.cardCornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(SettingsTheme.cardTint)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(SettingsTheme.hairline, lineWidth: 1)
            }
            .shadow(color: SettingsTheme.shadow, radius: 24, x: 0, y: 14)
    }
}

struct GlassSurface<Content: View>: View {
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: Content

    init(
        padding: CGFloat = SettingsMetrics.cardPadding,
        cornerRadius: CGFloat = SettingsMetrics.cardCornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        LiquidPanel(padding: padding, cornerRadius: cornerRadius) {
            content
        }
    }
}

struct CardSurface<Content: View>: View {
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: Content

    init(
        padding: CGFloat = SettingsMetrics.cardPadding,
        cornerRadius: CGFloat = SettingsMetrics.cardCornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        GlassSurface(padding: padding, cornerRadius: cornerRadius) {
            content
        }
    }
}

struct InsetPanel<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SettingsMetrics.rowPadding)
            .background(
                RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.42))
                    .overlay(
                        RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            )
    }
}

struct SettingsGroup<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                .fill(SettingsTheme.cardTintStrong.opacity(0.52))
        )
        .overlay(
            RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                .strokeBorder(SettingsTheme.hairline.opacity(0.82), lineWidth: 1)
        )
    }
}

struct SettingsHeroHeader: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(SettingsTheme.primary)
                .frame(width: 42, height: 42)
                .background(SettingsTheme.cardTintStrong, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(SettingsTheme.hairline, lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }
}

struct SettingsSectionLabel: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.82))

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 2)
    }
}

struct LiquidButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    enum Kind {
        case primary
        case secondary
        case destructive
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(isEnabled ? foreground : Color.secondary.opacity(0.72))
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isEnabled ? fill.opacity(configuration.isPressed ? 0.76 : 1.0) : SettingsTheme.disabledFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            }
            .shadow(color: shadow.opacity(configuration.isPressed ? 0.10 : 0.18), radius: 12, x: 0, y: 7)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(isEnabled ? 1.0 : 0.70)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary:
            return .white
        case .secondary:
            return SettingsTheme.primary
        case .destructive:
            return SettingsTheme.danger
        }
    }

    private var fill: Color {
        switch kind {
        case .primary:
            return SettingsTheme.primary
        case .secondary:
            return SettingsTheme.cardTintStrong
        case .destructive:
            return SettingsTheme.danger.opacity(0.08)
        }
    }

    private var stroke: Color {
        switch kind {
        case .primary:
            return Color.white.opacity(0.34)
        case .secondary:
            return SettingsTheme.primary.opacity(0.16)
        case .destructive:
            return SettingsTheme.danger.opacity(0.18)
        }
    }

    private var shadow: Color {
        switch kind {
        case .primary:
            return SettingsTheme.primary
        case .secondary:
            return Color.black
        case .destructive:
            return SettingsTheme.danger
        }
    }
}

struct LiquidIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(isEnabled ? SettingsTheme.primary : Color.secondary.opacity(0.72))
            .frame(width: 34, height: 34)
            .background {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(isEnabled ? SettingsTheme.cardTintStrong.opacity(configuration.isPressed ? 0.72 : 1.0) : SettingsTheme.disabledFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(SettingsTheme.primary.opacity(0.14), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, SettingsMetrics.labelColumnWidth + 30)
    }
}

struct SectionHeaderView: View {
    let title: String
    let subtitle: String?
    let systemImage: String?

    init(title: String, subtitle: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 18, height: 18)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
    }
}

struct StatusPill: View {
    let title: String
    let tint: Color
    let systemImage: String?

    init(title: String, tint: Color, systemImage: String? = nil) {
        self.title = title
        self.tint = tint
        self.systemImage = systemImage
    }

    var body: some View {
        Label {
            Text(title)
                .font(.caption.weight(.semibold))
        } icon: {
            if let systemImage {
                Image(systemName: systemImage)
            }
        }
        .labelStyle(.titleAndIcon)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(tint)
        .background(
            Capsule(style: .continuous)
                .fill(tint.opacity(0.12))
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(tint.opacity(0.18), lineWidth: 1)
        )
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let tint: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)

                Spacer(minLength: 0)
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(tint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

struct SidebarRowView: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let tint: Color
    let leadingIcon: String?
    let trailingLabel: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? tint : .secondary)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isSelected ? tint.opacity(0.14) : Color.primary.opacity(0.06))
                    )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if let trailingLabel {
                Text(trailingLabel)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(isSelected ? tint : .secondary)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                    )
            }
        }
        .padding(SettingsMetrics.compactRowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: SettingsMetrics.rowCornerRadius, style: .continuous)
                .fill(isSelected ? tint.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SettingsMetrics.rowCornerRadius, style: .continuous)
                .strokeBorder(isSelected ? tint.opacity(0.3) : Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

struct SettingsFieldRow<Content: View>: View {
    let title: String
    let subtitle: String?
    let alignment: VerticalAlignment
    private let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        HStack(alignment: alignment, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: SettingsMetrics.labelColumnWidth, alignment: .leading)

            Spacer(minLength: 0)

            content
        }
        .padding(SettingsMetrics.rowPadding)
        .frame(minHeight: 46)
        .contentShape(Rectangle())
    }
}

struct SettingsGroupRow<Content: View>: View {
    let title: String
    let subtitle: String?
    let alignment: VerticalAlignment
    private let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        HStack(alignment: alignment, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: SettingsMetrics.labelColumnWidth, alignment: .leading)

            Spacer(minLength: 0)

            content
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, SettingsMetrics.rowPadding)
        .padding(.vertical, 10)
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }
}

struct MappingToken: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(.thinMaterial, in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
            )
    }
}

struct SourceListRowView: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let leadingIcon: String
    let trailingLabel: String?

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: leadingIcon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11.5, weight: .regular, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if let trailingLabel {
                Text(trailingLabel)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.thinMaterial, in: Capsule(style: .continuous))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .background(
            Capsule(style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.clear)
        )
    }
}

struct MenuActionRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.72))
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(0.08))
                )

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.72))
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
        .contentShape(Rectangle())
    }
}
