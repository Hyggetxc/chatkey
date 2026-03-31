import Testing
@testable import ChatKey
import ApplicationServices
import Foundation

@Test
func defaultRuleIncludesChatPresetMappings() async throws {
    let rule = AppRule(appName: "WeChat", bundleId: "com.tencent.xinWeChat")

    #expect(rule.mappings.count == 2)
    #expect(rule.mappings.contains { $0.trigger == .return && $0.output == .shiftReturn })
    #expect(rule.mappings.contains { $0.trigger == .commandReturn && $0.output == .return })
}

@Test
func settingsDefaultToEnabledChineseAwareConfiguration() async throws {
    let settings = AppSettings()

    #expect(settings.isEnabled)
    #expect(settings.autoCheckForUpdates)
    #expect(settings.language == .system)
}

@Test
func triggerRoutingRecognizesSupportedReturnCombos() async throws {
    #expect(KeyEventRouting.trigger(forKeyCode: 36, flags: []) == .return)
    #expect(KeyEventRouting.trigger(forKeyCode: 36, flags: .maskCommand) == .commandReturn)
    #expect(KeyEventRouting.trigger(forKeyCode: 36, flags: .maskShift) == .shiftReturn)
    #expect(KeyEventRouting.trigger(forKeyCode: 36, flags: [.maskCommand, .maskShift]) == nil)
}

@Test
func routingDecisionMatchesEnabledRuleForFrontmostApp() async throws {
    let context = EventRoutingContext(
        settings: AppSettings(),
        currentApp: AppDescriptor(name: "WeChat", bundleId: "com.tencent.xinWeChat"),
        rules: [
            AppRule(
                appName: "WeChat",
                bundleId: "com.tencent.xinWeChat",
                mappings: [
                    KeyMapping(trigger: .return, output: .shiftReturn),
                    KeyMapping(trigger: .commandReturn, output: .return),
                ]
            )
        ]
    )

    let decision = KeyEventRouting.decision(forKeyCode: 36, flags: .maskCommand, context: context)

    #expect(decision?.ruleName == "WeChat")
    #expect(decision?.trigger == .commandReturn)
    #expect(decision?.output == .return)
}

@Test
func installedAppsCatalogDeduplicatesBundleIdentifiersAndSortsByName() async throws {
    let apps = InstalledAppsCatalogStore.normalizedApps(
        from: [
            InstalledAppCandidate(
                name: "Safari",
                bundleId: "com.apple.Safari",
                path: "/System/Applications/Safari.app"
            ),
            InstalledAppCandidate(
                name: "WeChat",
                bundleId: "com.tencent.xinWeChat",
                path: "/Applications/WeChat.app"
            ),
            InstalledAppCandidate(
                name: "Safari Beta",
                bundleId: "com.apple.Safari",
                path: "/Applications/Safari.app"
            ),
        ]
    )

    #expect(apps.map(\.bundleId) == ["com.apple.Safari", "com.tencent.xinWeChat"])
    #expect(apps.map(\.name) == ["Safari Beta", "WeChat"])
}

@Test
func updateConfigurationResolvesEnvironmentBeforeInfoDictionary() async throws {
    let configuration = UpdateConfiguration.resolved(
        infoDictionary: [
            "CHATKEY_GITHUB_OWNER": "info-owner",
            "CHATKEY_GITHUB_REPOSITORY": "info-repo"
        ],
        environment: [
            "CHATKEY_GITHUB_OWNER": "env-owner",
            "CHATKEY_GITHUB_REPOSITORY": "env-repo"
        ]
    )

    #expect(configuration.latestReleaseAPIURL?.absoluteString == "https://api.github.com/repos/env-owner/env-repo/releases/latest")
    #expect(configuration.releasesPageURL?.absoluteString == "https://github.com/env-owner/env-repo/releases")
}

@Test
func updateConfigurationFallsBackToInfoDictionaryValues() async throws {
    let configuration = UpdateConfiguration.resolved(
        infoDictionary: [
            "GitHubOwner": "info-owner",
            "GitHubRepository": "info-repo"
        ],
        environment: [:]
    )

    #expect(configuration.latestReleaseAPIURL?.absoluteString == "https://api.github.com/repos/info-owner/info-repo/releases/latest")
    #expect(configuration.releasesPageURL?.absoluteString == "https://github.com/info-owner/info-repo/releases")
}

@Test
func updateConfigurationUsesDefaultsWhenNoConfigIsPresent() async throws {
    let configuration = UpdateConfiguration.resolved(
        defaultOwner: "Hyggetxc",
        defaultRepository: "chatkey",
        infoDictionary: [:],
        environment: [:]
    )

    #expect(configuration.latestReleaseAPIURL?.absoluteString == "https://api.github.com/repos/Hyggetxc/chatkey/releases/latest")
    #expect(configuration.releasesPageURL?.absoluteString == "https://github.com/Hyggetxc/chatkey/releases")
}
