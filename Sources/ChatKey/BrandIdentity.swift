import SwiftUI

enum AppVisualStatus: Equatable {
    case ready
    case paused
    case permissionMissing

    static func make(isEnabled: Bool, isPermissionTrusted: Bool) -> AppVisualStatus {
        guard isPermissionTrusted else {
            return .permissionMissing
        }

        return isEnabled ? .ready : .paused
    }
}

enum BrandIdentity {
    static let displayName = "ChatKey"
}

struct MenuBarStatusIcon: View {
    let status: AppVisualStatus

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(.primary, lineWidth: 1.35)
                .frame(width: 18, height: 14)

            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    keyDot
                    keyDot
                    keyDot
                }

                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(.primary)
                    .frame(width: 10, height: 1.8)
            }
            .offset(y: -0.2)

            returnBadge
                .offset(x: 5.8, y: 4.9)

            statusBadge
                .offset(x: -5.8, y: -4.8)
        }
        .frame(width: 20, height: 16)
        .accessibilityHidden(true)
    }

    private var keyDot: some View {
        Circle()
            .fill(.primary)
            .frame(width: 1.9, height: 1.9)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .ready:
            badge(symbolName: "checkmark", symbolSize: 4.8, diameter: 7.6)
        case .paused:
            badge(symbolName: "pause.fill", symbolSize: 4.4, diameter: 7.6)
        case .permissionMissing:
            badge(symbolName: "exclamationmark", symbolSize: 5.2, diameter: 7.6)
        }
    }

    private var returnBadge: some View {
        ZStack {
            Circle()
                .fill(.primary)
                .frame(width: 8.5, height: 8.5)

            Image(systemName: "arrow.turn.down.left")
                .font(.system(size: 5.6, weight: .bold))
                .foregroundStyle(.background)
        }
    }

    // 品牌角标固定表达“Return / 键位切换”语义；
    // 左上角的小状态点只负责表示 ready / paused / missing permission 三种运行状态。
    private func badge(symbolName: String, symbolSize: CGFloat, diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(.primary)
                .frame(width: diameter, height: diameter)

            Image(systemName: symbolName)
                .font(.system(size: symbolSize, weight: .bold))
                .foregroundStyle(.background)
        }
    }
}
