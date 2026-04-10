import AppKit
import Combine
import Foundation

struct UpdateConfiguration {
    var owner: String?
    var repository: String?

    static let placeholder = UpdateConfiguration(owner: nil, repository: nil)

    static func resolved(
        defaultOwner: String? = nil,
        defaultRepository: String? = nil,
        infoDictionary: [String: Any]? = Bundle.main.infoDictionary,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> UpdateConfiguration {
        UpdateConfiguration(
            owner: Self.configValue(
                environmentKey: "CHATKEY_GITHUB_OWNER",
                infoKeys: ["CHATKEY_GITHUB_OWNER", "GitHubOwner"],
                environment: environment,
                infoDictionary: infoDictionary
            ) ?? defaultOwner,
            repository: Self.configValue(
                environmentKey: "CHATKEY_GITHUB_REPOSITORY",
                infoKeys: ["CHATKEY_GITHUB_REPOSITORY", "GitHubRepository"],
                environment: environment,
                infoDictionary: infoDictionary
            ) ?? defaultRepository
        )
    }

    var latestReleaseAPIURL: URL? {
        guard let owner, let repository else {
            return nil
        }

        return URL(string: "https://api.github.com/repos/\(owner)/\(repository)/releases/latest")
    }

    var releasesAPIURL: URL? {
        guard let owner, let repository else {
            return nil
        }

        return URL(string: "https://api.github.com/repos/\(owner)/\(repository)/releases")
    }

    var releasesPageURL: URL? {
        guard let owner, let repository else {
            return nil
        }

        return URL(string: "https://github.com/\(owner)/\(repository)/releases")
    }

    private static func configValue(
        environmentKey: String,
        infoKeys: [String],
        environment: [String: String],
        infoDictionary: [String: Any]?
    ) -> String? {
        if let value = environment[environmentKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
           !value.isEmpty
        {
            return value
        }

        for key in infoKeys {
            if let rawValue = infoDictionary?[key] as? String {
                let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty {
                    return value
                }
            }

            if let rawValue = infoDictionary?[key] as? NSString {
                let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty {
                    return value
                }
            }

            if let rawValue = infoDictionary?[key] as? CustomStringConvertible {
                let value = rawValue.description.trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty {
                    return value
                }
            }
        }

        return nil
    }
}

@MainActor
final class UpdateManager: ObservableObject {
    @Published private(set) var status: UpdateStatus = .idle

    private let configuration: UpdateConfiguration
    private let session: URLSession

    init(
        configuration: UpdateConfiguration = .placeholder,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }

    var currentVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "0.1.0-dev"
    }

    func scheduleStartupCheck(using settingsStore: SettingsStore) {
        guard settingsStore.settings.autoCheckForUpdates else {
            return
        }

        guard shouldAutoCheck(lastCheckedAt: settingsStore.settings.lastUpdateCheckAt) else {
            return
        }

        Task {
            await checkForUpdates(using: settingsStore)
        }
    }

    func checkForUpdates(using settingsStore: SettingsStore) async {
        guard configuration.latestReleaseAPIURL != nil else {
            status = .repositoryNotConfigured
            return
        }

        status = .checking
        defer {
            settingsStore.recordUpdateCheck()
        }

        do {
            let release = try await fetchLatestAvailableRelease()

            if Self.normalizedTag(release.tagName) == Self.normalizedTag(currentVersion) {
                status = .upToDate
            } else {
                status = .updateAvailable(release)
            }
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    func openReleasesPage() {
        guard let releasesPageURL = configuration.releasesPageURL else {
            return
        }

        NSWorkspace.shared.open(releasesPageURL)
    }

    private func shouldAutoCheck(lastCheckedAt: Date?) -> Bool {
        guard let lastCheckedAt else {
            return true
        }

        return Date().timeIntervalSince(lastCheckedAt) >= 60 * 60 * 24
    }

    private func fetchLatestAvailableRelease() async throws -> GitHubRelease {
        let decoder = JSONDecoder()

        if let latestReleaseAPIURL = configuration.latestReleaseAPIURL {
            let (data, response) = try await session.data(from: latestReleaseAPIURL)
            if let httpResponse = response as? HTTPURLResponse, (200 ..< 300).contains(httpResponse.statusCode) {
                return try decoder.decode(GitHubRelease.self, from: data)
            }
        }

        guard let releasesAPIURL = configuration.releasesAPIURL else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: releasesAPIURL)
        guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let releases = try decoder.decode([GitHubRelease].self, from: data)
        guard let release = releases.first(where: { $0.draft != true }) else {
            throw URLError(.resourceUnavailable)
        }

        return release
    }

    private static func normalizedTag(_ rawValue: String) -> String {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let firstCharacter = trimmed.first, firstCharacter == "v" || firstCharacter == "V" else {
            return trimmed
        }

        return String(trimmed.dropFirst())
    }
}
