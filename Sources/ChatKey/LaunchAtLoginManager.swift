import Foundation
import ServiceManagement

enum LaunchAtLoginManager {
    static func setEnabled(_ isEnabled: Bool) {
        do {
            if isEnabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            assertionFailure("Failed to update launch-at-login setting: \(error)")
        }
    }
}
