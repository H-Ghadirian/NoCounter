import Foundation
import WatchConnectivity
import SwiftData

final class PhoneWC: NSObject, WCSessionDelegate {
    static let shared = PhoneWC()

    var modelContext: ModelContext?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }

    // ✅ Add this version so we can reply
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            guard let ctx = self.modelContext else {
                replyHandler([:])
                return
            }

            if message[WCKeys.requestState] != nil {
                let total = (try? ctx.fetchCount(FetchDescriptor<NoEvent>())) ?? 0
                replyHandler([WCKeys.allTimeCount: total])
                return
            }

            // handle add/undo
            if message[WCKeys.addNo] != nil {
                ctx.insert(NoEvent())
            } else if message[WCKeys.undoNo] != nil {
                let descriptor = FetchDescriptor<NoEvent>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
                if let latest = try? ctx.fetch(descriptor).first {
                    ctx.delete(latest)
                }
            }

            // optionally reply with updated count after changes
            let total = (try? ctx.fetchCount(FetchDescriptor<NoEvent>())) ?? 0
            replyHandler([WCKeys.allTimeCount: total])
        }
    }

    // keep these for background delivery
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handle(message: userInfo)
    }

    private func handle(message: [String: Any]) {
        DispatchQueue.main.async {
            guard let ctx = self.modelContext else { return }

            if message[WCKeys.addNo] != nil {
                ctx.insert(NoEvent())
            } else if message[WCKeys.undoNo] != nil {
                let descriptor = FetchDescriptor<NoEvent>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
                if let latest = try? ctx.fetch(descriptor).first {
                    ctx.delete(latest)
                }
            }
        }
    }
}
