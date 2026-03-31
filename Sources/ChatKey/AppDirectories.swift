import Foundation

enum AppDirectories {
    private static let appFolderName = "ChatKey"

    static var applicationSupportDirectory: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appURL = baseURL.appendingPathComponent(appFolderName, isDirectory: true)

        if !FileManager.default.fileExists(atPath: appURL.path) {
            try? FileManager.default.createDirectory(at: appURL, withIntermediateDirectories: true)
        }

        return appURL
    }

    static var rulesFileURL: URL {
        applicationSupportDirectory.appendingPathComponent("rules.json")
    }

    static var settingsFileURL: URL {
        applicationSupportDirectory.appendingPathComponent("settings.json")
    }
}
