import Foundation
import WatchConnectivity

extension Notification.Name {
    static let watchCountDidUpdate = Notification.Name("watchCountDidUpdate")
}

final class WatchWC: NSObject, WCSessionDelegate {
    static let shared = WatchWC()
    private let cacheKey = "cached_no_count"
    private var cachedCount: Int {
        get { UserDefaults.standard.integer(forKey: cacheKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: self.cacheKey)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .watchCountDidUpdate, object: newValue)
            }
        }
    }

    private override init() {
        super.init()
        print("WatchWC - init")
        if WCSession.isSupported() {
            print("WatchWC - WCSession isSupported")
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func requestState(completion: @escaping (Int?) -> Void) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else {
            print("WatchWC - session is not Reachable or not activated")
            completion(cachedCount)
            return
        }

        session.sendMessage([WCKeys.requestState: true], replyHandler: { reply in
            let count = reply[WCKeys.allTimeCount] as? Int
            if let count { self.cachedCount = count }
            completion(self.cachedCount)
        }, errorHandler: { _ in
            completion(self.cachedCount)
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
            print("WatchWC - activationState not .activated")
            completion?(cachedCount)
            return
        }

        if session.isReachable {
            session.sendMessage(message, replyHandler: { reply in
                print("WatchWC - replyHandler called with \(reply)")
                let count = reply[WCKeys.allTimeCount] as? Int
                if let count { self.cachedCount = count }
                print("WatchWC - before completion")
                completion?(self.cachedCount)
            }, errorHandler: { _ in
                print("WatchWC - errorHandler called")
                completion?(self.cachedCount)
            })
        } else {
            print("WatchWC - session is not Reachable")
            session.transferUserInfo(message)
            completion?(self.cachedCount)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    // ✅ REQUIRED for updateApplicationContext() deliveries
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let count = applicationContext[WCKeys.allTimeCount] as? Int {
                print("WatchWC - didReceiveApplicationContext")
                self.cachedCount = count
            }
        }
    }

    // (Optional but recommended if you use transferUserInfo from either side)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let count = userInfo[WCKeys.allTimeCount] as? Int {
                print("WatchWC - didReceiveUserInfo")
                self.cachedCount = count
            }
        }
    }
}
