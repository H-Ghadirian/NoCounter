import Foundation
import WatchConnectivity

final class WatchWC: NSObject, WCSessionDelegate {
    static let shared = WatchWC()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func requestState(completion: @escaping (Int?) -> Void) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else {
            completion(nil)
            return
        }

        session.sendMessage([WCKeys.requestState: true], replyHandler: { reply in
            let count = reply[WCKeys.allTimeCount] as? Int
            completion(count)
        }, errorHandler: { _ in
            completion(nil)
        })
    }

    func sendAdd(completion: ((Int?) -> Void)? = nil) {
        send(message: [WCKeys.addNo: 1], completion: completion)
    }

    func sendUndo(completion: ((Int?) -> Void)? = nil) {
        send(message: [WCKeys.undoNo: 1], completion: completion)
    }

    private func send(message: [String: Any], completion: ((Int?) -> Void)? = nil) {
        let session = WCSession.default
        guard session.activationState == .activated else {
            completion?(nil)
            return
        }

        if session.isReachable {
            session.sendMessage(message, replyHandler: { reply in
                completion?(reply[WCKeys.allTimeCount] as? Int)
            }, errorHandler: { _ in
                completion?(nil)
            })
        } else {
            session.transferUserInfo(message)
            completion?(nil)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
