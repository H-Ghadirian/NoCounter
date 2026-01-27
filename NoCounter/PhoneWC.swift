import WatchConnectivity
import SwiftData
import WidgetKit

final class PhoneWC: NSObject, WCSessionDelegate {
    static let shared = PhoneWC()

    var modelContext: ModelContext?

    private override init() {
        super.init()
        print("PhoneWC init")
        if WCSession.isSupported() {
            print("WCSession.isSupported")
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    private func totalCount() -> Int {
        guard let ctx = modelContext else { return 0 }
        return (try? ctx.fetchCount(FetchDescriptor<NoEvent>())) ?? 0
    }

    private func syncWidgetCount(_ total: Int) {
        print("PhoneWC syncWidgetCount: \(total)")
        NoStore.set(total)
        WidgetCenter.shared.reloadAllTimelines()
        try? WCSession.default.updateApplicationContext([WCKeys.allTimeCount: total])
    }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        message.forEach { (key: String, value: Any) in
            print("PhoneWC session key: \(key), value:\(value)")
        }

        DispatchQueue.main.async {
            guard let ctx = self.modelContext else {
                replyHandler([WCKeys.allTimeCount: 0])
                return
            }

            if message[WCKeys.addNo] != nil {
                ctx.insert(NoEvent())
            } else if message[WCKeys.undoNo] != nil {
                let fd = FetchDescriptor<NoEvent>(
                    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                )
                if let last = try? ctx.fetch(fd).first {
                    ctx.delete(last)
                }
            }

            let total = self.totalCount()
            self.syncWidgetCount(total)
            replyHandler([WCKeys.allTimeCount: total])
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        userInfo.forEach { (key: String, value: Any) in
            print("PhoneWC didReceiveUserInfo key: \(key), value:\(value)")
        }

        DispatchQueue.main.async {
            guard let ctx = self.modelContext else { return }

            if userInfo[WCKeys.addNo] != nil {
                ctx.insert(NoEvent())
            } else if userInfo[WCKeys.undoNo] != nil {
                let fd = FetchDescriptor<NoEvent>(
                    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                )
                if let last = try? ctx.fetch(fd).first {
                    ctx.delete(last)
                }
            }

            let total = self.totalCount()
            self.syncWidgetCount(total) // updates widget + pushes applicationContext to watch
        }
    }

    // delegate stubs...
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
