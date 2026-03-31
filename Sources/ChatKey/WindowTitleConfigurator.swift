import AppKit
import SwiftUI

struct WindowTitleConfigurator: NSViewRepresentable {
    let title: String

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        updateWindow(for: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        updateWindow(for: nsView)
    }

    // macOS 的 Settings 场景会把当前 Tab 名称拿去当窗口标题。
    // 这里主动回写标题，保证整个设置窗口始终显示“设置 / Settings”。
    private func updateWindow(for view: NSView) {
        DispatchQueue.main.async {
            guard let window = view.window else {
                return
            }

            window.title = title
        }
    }
}
