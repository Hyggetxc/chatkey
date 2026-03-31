import ApplicationServices
import Foundation

struct EventRoutingContext: Equatable {
    var settings: AppSettings
    var currentApp: AppDescriptor?
    var rules: [AppRule]
}

enum KeyEventRouting {
    // MVP 只处理 Return 家族按键，这样可以把聊天场景的核心链路先做稳定。
    static let supportedReturnKeyCodes: Set<CGKeyCode> = [36, 76]

    static func trigger(forKeyCode keyCode: CGKeyCode, flags: CGEventFlags) -> TriggerKey? {
        guard supportedReturnKeyCodes.contains(keyCode) else {
            return nil
        }

        switch normalizedModifiers(from: flags) {
        case []:
            return .return
        case .maskShift:
            return .shiftReturn
        case .maskCommand:
            return .commandReturn
        case .maskAlternate:
            return .optionReturn
        case .maskControl:
            return .controlReturn
        default:
            return nil
        }
    }

    static func decision(
        forKeyCode keyCode: CGKeyCode,
        flags: CGEventFlags,
        context: EventRoutingContext
    ) -> RoutingDecision? {
        guard context.settings.isEnabled else {
            return nil
        }

        guard
            let app = context.currentApp,
            let trigger = trigger(forKeyCode: keyCode, flags: flags),
            let rule = context.rules.first(where: { $0.isEnabled && $0.bundleId == app.bundleId }),
            let mapping = rule.mappings.first(where: { $0.trigger == trigger && $0.output != .none })
        else {
            return nil
        }

        return RoutingDecision(
            ruleID: rule.id,
            ruleName: rule.appName,
            bundleId: rule.bundleId,
            trigger: trigger,
            output: mapping.output
        )
    }

    static func normalizedModifiers(from flags: CGEventFlags) -> CGEventFlags {
        // 只保留我们当前支持的修饰键，避免 caps lock、fn 等状态误伤命中结果。
        flags.intersection([.maskShift, .maskCommand, .maskAlternate, .maskControl])
    }
}
