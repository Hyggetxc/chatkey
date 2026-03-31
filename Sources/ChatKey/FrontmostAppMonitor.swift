@preconcurrency import AppKit
import Combine
import Foundation

@MainActor
final class FrontmostAppMonitor: ObservableObject {
    @Published private(set) var currentApp: AppDescriptor?

    private let workspace: NSWorkspace
    private var observer: NSObjectProtocol?

    init(workspace: NSWorkspace = .shared) {
        self.workspace = workspace
        currentApp = Self.makeDescriptor(from: workspace.frontmostApplication)
        observer = workspace.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let runningApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication

            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                // 前台应用变化只同步应用级元信息，不在这里做任何按键逻辑判断。
                guard let app = runningApp else {
                    self.currentApp = nil
                    return
                }

                self.currentApp = Self.makeDescriptor(from: app)
            }
        }
    }

    private static func makeDescriptor(from app: NSRunningApplication?) -> AppDescriptor? {
        guard
            let app,
            let bundleId = app.bundleIdentifier
        else {
            return nil
        }

        let appName = app.localizedName ?? bundleId
        return AppDescriptor(name: appName, bundleId: bundleId)
    }
}
