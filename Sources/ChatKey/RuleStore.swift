import Combine
import Foundation

@MainActor
final class RuleStore: ObservableObject {
    @Published private(set) var rules: [AppRule]

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL = AppDirectories.rulesFileURL) {
        self.fileURL = fileURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        if
            let data = try? Data(contentsOf: fileURL),
            let stored = try? decoder.decode([AppRule].self, from: data)
        {
            rules = stored
        } else {
            rules = []
            save()
        }
    }

    func addRule(for app: AppDescriptor?) -> UUID {
        let descriptor = app ?? AppDescriptor(name: "New App", bundleId: "com.example.new-app")
        let rule = AppRule(appName: descriptor.name, bundleId: descriptor.bundleId)
        rules.append(rule)
        save()
        return rule.id
    }

    func ensureRule(for app: AppDescriptor) -> UUID {
        if let existingRule = rule(forBundleID: app.bundleId) {
            return existingRule.id
        }

        return addRule(for: app)
    }

    func matchingRule(for app: AppDescriptor?) -> AppRule? {
        guard let app else {
            return nil
        }

        // 规则命中目前只按 bundleId 精确匹配，先把桌面 IM 场景做稳。
        return rules.first { $0.isEnabled && $0.bundleId == app.bundleId }
    }

    func rule(forBundleID bundleId: String) -> AppRule? {
        rules.first { $0.bundleId == bundleId }
    }

    func updateRuleEnabled(_ isEnabled: Bool, ruleID: UUID) {
        updateRule(ruleID) { rule in
            rule.isEnabled = isEnabled
        }
    }

    func updateRuleAppName(_ appName: String, ruleID: UUID) {
        updateRule(ruleID) { rule in
            rule.appName = appName
        }
    }

    func updateRuleBundleID(_ bundleId: String, ruleID: UUID) {
        updateRule(ruleID) { rule in
            rule.bundleId = bundleId
        }
    }

    func updateRuleNotes(_ notes: String, ruleID: UUID) {
        updateRule(ruleID) { rule in
            rule.notes = notes
        }
    }

    func addMapping(to ruleID: UUID) {
        updateRule(ruleID) { rule in
            let usedTriggers = Set(rule.mappings.map(\.trigger))
            let nextTrigger = TriggerKey.allCases.first(where: { !usedTriggers.contains($0) }) ?? .return
            rule.mappings.append(KeyMapping(trigger: nextTrigger, output: .none))
        }
    }

    func removeMapping(ruleID: UUID, mappingID: UUID) {
        updateRule(ruleID) { rule in
            rule.mappings.removeAll { $0.id == mappingID }
        }
    }

    func updateMappingTrigger(ruleID: UUID, mappingID: UUID, trigger: TriggerKey) {
        updateRule(ruleID) { rule in
            guard let index = rule.mappings.firstIndex(where: { $0.id == mappingID }) else {
                return
            }

            rule.mappings[index].trigger = trigger
        }
    }

    func updateMappingOutput(ruleID: UUID, mappingID: UUID, output: OutputAction) {
        updateRule(ruleID) { rule in
            guard let index = rule.mappings.firstIndex(where: { $0.id == mappingID }) else {
                return
            }

            rule.mappings[index].output = output
        }
    }

    func deleteRule(ruleID: UUID) {
        rules.removeAll { $0.id == ruleID }
        save()
    }

    private func updateRule(_ ruleID: UUID, mutate: (inout AppRule) -> Void) {
        guard let index = rules.firstIndex(where: { $0.id == ruleID }) else {
            return
        }

        mutate(&rules[index])
        rules[index].updatedAt = .now
        save()
    }

    private func save() {
        do {
            let data = try encoder.encode(rules)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            assertionFailure("Failed to save rules: \(error)")
        }
    }
}
