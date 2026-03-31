import ApplicationServices
import Foundation

struct DispatchResult: Equatable {
    let success: Bool
    let message: String?
}

final class ActionDispatcher {
    // 用固定标记值给我们自己发送的事件打标签，避免事件被监听器再次处理。
    private let syntheticEventMarker: Int64 = 0x4348_4B59
    private let returnKeyCode: CGKeyCode = 36

    func isSyntheticEvent(_ event: CGEvent) -> Bool {
        event.getIntegerValueField(.eventSourceUserData) == syntheticEventMarker
    }

    func dispatch(_ action: OutputAction) -> DispatchResult {
        guard action != .none else {
            return DispatchResult(success: true, message: nil)
        }

        guard let source = CGEventSource(stateID: .hidSystemState) else {
            return DispatchResult(success: false, message: "Failed to create event source.")
        }

        let flags = modifierFlags(for: action)

        guard
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: returnKeyCode, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: returnKeyCode, keyDown: false)
        else {
            return DispatchResult(success: false, message: "Failed to create keyboard events.")
        }

        keyDown.flags = flags
        keyUp.flags = flags
        keyDown.setIntegerValueField(.eventSourceUserData, value: syntheticEventMarker)
        keyUp.setIntegerValueField(.eventSourceUserData, value: syntheticEventMarker)

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)

        return DispatchResult(success: true, message: nil)
    }

    private func modifierFlags(for action: OutputAction) -> CGEventFlags {
        switch action {
        case .none, .return:
            return []
        case .shiftReturn:
            return .maskShift
        case .commandReturn:
            return .maskCommand
        case .optionReturn:
            return .maskAlternate
        case .controlReturn:
            return .maskControl
        }
    }
}
