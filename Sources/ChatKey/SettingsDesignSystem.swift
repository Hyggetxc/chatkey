import AppKit
import SwiftUI

enum SettingsMetrics {
    static let pageSpacing: CGFloat = 18
    static let sectionSpacing: CGFloat = 14
    static let cardPadding: CGFloat = 18
    static let rowPadding: CGFloat = 14
    static let compactRowPadding: CGFloat = 12
    static let cardCornerRadius: CGFloat = 20
    static let innerCornerRadius: CGFloat = 16
    static let rowCornerRadius: CGFloat = 14
    static let iconSize: CGFloat = 18
    static let badgeSize: CGFloat = 40
    static let labelColumnWidth: CGFloat = 154
    static let buttonMinWidth: CGFloat = 148
}

struct SettingsPageBackground: View {
    var body: some View {
        Color(nsColor: .windowBackgroundColor)
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
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 1)
                    )
            )
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
        .background(
            RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

struct MenuActionRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18, height: 18)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
    }
}
