import Foundation

struct InstalledAppCandidate: Equatable {
    let name: String
    let bundleId: String
    let path: String
}

enum InstalledAppsCatalogLoadState: Equatable {
    case idle
    case loading
    case loaded
}

@MainActor
final class InstalledAppsCatalogStore: ObservableObject {
    @Published private(set) var apps: [AppDescriptor] = []
    @Published private(set) var loadState: InstalledAppsCatalogLoadState = .idle

    private var loadTask: Task<Void, Never>?

    init(autoload: Bool = true) {
        if autoload {
            reload()
        }
    }

    deinit {
        loadTask?.cancel()
    }

    func reload() {
        loadTask?.cancel()
        loadState = .loading

        loadTask = Task { [weak self] in
            let candidates = await Self.discoverInstalledApps()
            guard let self, !Task.isCancelled else {
                return
            }

            apps = Self.normalizedApps(from: candidates)
            loadState = .loaded
        }
    }

    // 这里把“遍历磁盘上的 .app 包”和“供 UI 使用的应用列表”拆开，
    // 这样后续既能复用纯数据整理逻辑，也方便为扫描结果补单元测试。
    nonisolated static func normalizedApps(from candidates: [InstalledAppCandidate]) -> [AppDescriptor] {
        let orderedCandidates = candidates.sorted { lhs, rhs in
            let lhsRank = preferredPathRank(for: lhs.path)
            let rhsRank = preferredPathRank(for: rhs.path)

            if lhs.bundleId == rhs.bundleId {
                if lhsRank != rhsRank {
                    return lhsRank < rhsRank
                }

                if lhs.name != rhs.name {
                    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                }

                return lhs.path.localizedStandardCompare(rhs.path) == .orderedAscending
            }

            if lhs.name != rhs.name {
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }

            return lhs.bundleId.localizedStandardCompare(rhs.bundleId) == .orderedAscending
        }

        var uniqueCandidatesByBundleID: [String: InstalledAppCandidate] = [:]

        for candidate in orderedCandidates {
            guard uniqueCandidatesByBundleID[candidate.bundleId] == nil else {
                continue
            }

            uniqueCandidatesByBundleID[candidate.bundleId] = candidate
        }

        return uniqueCandidatesByBundleID.values
            .map { AppDescriptor(name: $0.name, bundleId: $0.bundleId) }
            .sorted { lhs, rhs in
                if lhs.name != rhs.name {
                    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                }

                return lhs.bundleId.localizedStandardCompare(rhs.bundleId) == .orderedAscending
            }
    }

    private nonisolated static func discoverInstalledApps() async -> [InstalledAppCandidate] {
        await Task.detached(priority: .utility) {
            appSearchRoots.flatMap { scanApplications(in: $0) }
        }.value
    }

    private nonisolated static func scanApplications(in rootURL: URL) -> [InstalledAppCandidate] {
        guard FileManager.default.fileExists(atPath: rootURL.path) else {
            return []
        }

        guard let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles],
            errorHandler: { _, _ in true }
        ) else {
            return []
        }

        var discoveredApps: [InstalledAppCandidate] = []

        for case let url as URL in enumerator {
            guard url.pathExtension == "app" else {
                continue
            }

            enumerator.skipDescendants()

            guard
                let bundle = Bundle(url: url),
                let bundleId = sanitized(bundle.bundleIdentifier),
                let name = readableName(from: bundle, fallbackURL: url)
            else {
                continue
            }

            discoveredApps.append(
                InstalledAppCandidate(
                    name: name,
                    bundleId: bundleId,
                    path: url.path
                )
            )
        }

        return discoveredApps
    }

    private nonisolated static var appSearchRoots: [URL] {
        var roots: [URL] = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications", isDirectory: true),
            URL(fileURLWithPath: "/Applications/Utilities", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications/Utilities", isDirectory: true),
        ]

        let userApplications = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            .appendingPathComponent("Applications", isDirectory: true)
        roots.append(userApplications)

        return Array(Set(roots)).sorted { $0.path < $1.path }
    }

    private nonisolated static func preferredPathRank(for path: String) -> Int {
        let homeApplicationsPrefix = "\(NSHomeDirectory())/Applications"

        if path.hasPrefix(homeApplicationsPrefix) {
            return 0
        }

        if path.hasPrefix("/Applications") {
            return 1
        }

        if path.hasPrefix("/System/Applications") {
            return 2
        }

        return 3
    }

    private nonisolated static func sanitized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }

    private nonisolated static func readableName(from bundle: Bundle, fallbackURL: URL) -> String? {
        if let displayName = sanitized(bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) {
            return displayName
        }

        if let bundleName = sanitized(bundle.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String) {
            return bundleName
        }

        return sanitized(fallbackURL.deletingPathExtension().lastPathComponent)
    }
}
