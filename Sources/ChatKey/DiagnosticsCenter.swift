import Foundation

@MainActor
final class DiagnosticsCenter: ObservableObject {
    @Published private(set) var listenerStatus: ListenerStatus = .inactive(.missingPermission)
    @Published private(set) var lastHandledEvent: HandledEventRecord?
    @Published private(set) var lastErrorMessage: String?

    func updateListenerStatus(_ status: ListenerStatus) {
        listenerStatus = status
    }

    func recordHandledEvent(_ event: HandledEventRecord) {
        lastHandledEvent = event
        lastErrorMessage = nil
    }

    func recordError(_ message: String) {
        // 诊断中心只保存最近一次关键错误，先保证排错效率，不做噪音过大的流水日志。
        lastErrorMessage = message
    }
}
