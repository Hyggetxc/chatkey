import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published private(set) var settings: AppSettings

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL = AppDirectories.settingsFileURL) {
        self.fileURL = fileURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        if
            let data = try? Data(contentsOf: fileURL),
            let stored = try? decoder.decode(AppSettings.self, from: data)
        {
            settings = stored
        } else {
            settings = AppSettings()
            save()
        }
    }

    func setAppEnabled(_ isEnabled: Bool) {
        settings.isEnabled = isEnabled
        save()
    }

    func setLanguage(_ language: AppLanguage) {
        settings.language = language
        save()
    }

    func setAutoCheckForUpdates(_ isEnabled: Bool) {
        settings.autoCheckForUpdates = isEnabled
        save()
    }

    func recordUpdateCheck(at date: Date = .now) {
        settings.lastUpdateCheckAt = date
        save()
    }

    private func save() {
        // 设置写入保持原子性，避免应用异常退出时把 JSON 写坏。
        do {
            let data = try encoder.encode(settings)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            assertionFailure("Failed to save settings: \(error)")
        }
    }
}
