import Foundation

struct AppDescriptor: Codable, Equatable, Identifiable, Hashable {
    let id: String
    var name: String
    var bundleId: String

    init(name: String, bundleId: String) {
        self.id = bundleId
        self.name = name
        self.bundleId = bundleId
    }
}

enum TriggerKey: String, Codable, CaseIterable, Identifiable {
    case `return`
    case shiftReturn
    case commandReturn
    case optionReturn
    case controlReturn

    var id: String { rawValue }
}

enum OutputAction: String, Codable, CaseIterable, Identifiable {
    case none
    case `return`
    case shiftReturn
    case commandReturn
    case optionReturn
    case controlReturn

    var id: String { rawValue }
}

struct KeyMapping: Codable, Equatable, Identifiable {
    let id: UUID
    var trigger: TriggerKey
    var output: OutputAction

    init(id: UUID = UUID(), trigger: TriggerKey, output: OutputAction) {
        self.id = id
        self.trigger = trigger
        self.output = output
    }
}

struct AppRule: Codable, Equatable, Identifiable {
    let id: UUID
    var appName: String
    var bundleId: String
    var isEnabled: Bool
    var mappings: [KeyMapping]
    var notes: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        appName: String,
        bundleId: String,
        isEnabled: Bool = true,
        mappings: [KeyMapping] = AppRule.defaultMappings,
        notes: String = "",
        updatedAt: Date = .now
    ) {
        self.id = id
        self.appName = appName
        self.bundleId = bundleId
        self.isEnabled = isEnabled
        self.mappings = mappings
        self.notes = notes
        self.updatedAt = updatedAt
    }

    static let defaultMappings: [KeyMapping] = [
        KeyMapping(trigger: .return, output: .shiftReturn),
        KeyMapping(trigger: .commandReturn, output: .return),
    ]
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case zhHans = "zh-Hans"
    case en

    var id: String { rawValue }

    var resolvedLanguage: AppLanguage {
        guard self == .system else {
            return self
        }

        if Locale.preferredLanguages.contains(where: { $0.hasPrefix("zh-Hans") || $0.hasPrefix("zh") }) {
            return .zhHans
        }

        return .en
    }
}

struct AppSettings: Codable, Equatable {
    var isEnabled: Bool = true
    var language: AppLanguage = .system
    var autoCheckForUpdates: Bool = true
    var lastUpdateCheckAt: Date?
}

struct GitHubRelease: Codable, Equatable {
    var tagName: String
    var htmlURL: URL
    var body: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case body
    }
}

enum UpdateStatus: Equatable {
    case idle
    case checking
    case upToDate
    case updateAvailable(GitHubRelease)
    case repositoryNotConfigured
    case failed(String)
}

enum ListenerInactiveReason: Equatable {
    case disabledByUser
    case missingPermission
}

enum ListenerStatus: Equatable {
    case active
    case inactive(ListenerInactiveReason)
    case failed(String)
}

struct RoutingDecision: Equatable {
    let ruleID: UUID
    let ruleName: String
    let bundleId: String
    let trigger: TriggerKey
    let output: OutputAction
}

struct HandledEventRecord: Equatable {
    let timestamp: Date
    let appName: String
    let bundleId: String
    let trigger: TriggerKey
    let output: OutputAction
    let ruleName: String
}
