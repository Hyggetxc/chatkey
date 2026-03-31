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
            Image(systemName: "keyboard")
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(.primary)

            statusBadge
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: -0.3, y: 0.2)
        }
        .frame(width: 18, height: 14)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .ready:
            badge(symbolName: "checkmark", symbolSize: 4.2, diameter: 6.8)
        case .paused:
            badge(symbolName: "pause.fill", symbolSize: 4.0, diameter: 6.8)
        case .permissionMissing:
            badge(symbolName: "exclamationmark", symbolSize: 4.6, diameter: 6.8)
        }
    }

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
