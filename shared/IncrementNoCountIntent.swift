import AppIntents
import SwiftData
import WidgetKit
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

struct IncrementNoCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment No Counter"
    static var description = IntentDescription(
        "Increment the No counter without opening the app."
    )
    static var openAppWhenRun: Bool = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult {
        let container = NoModelContainer.makeContainer()
        let ctx = container.mainContext

        ctx.insert(NoEvent())
        try? ctx.save()

        let total = (try? ctx.fetchCount(FetchDescriptor<NoEvent>()))
        let all = total ?? (NoStore.count() + 1)
        NoStore.set(all)
        WidgetCenter.shared.reloadAllTimelines()

        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            let session = WCSession.default
            var sent = false
            #if !os(watchOS)
            if session.isPaired && session.isWatchAppInstalled {
                sent = (try? session.updateApplicationContext(
                    [WCKeys.allTimeCount: all]
                )) != nil
            }
            #else
            sent = (try? session.updateApplicationContext(
                [WCKeys.allTimeCount: all]
            )) != nil
            #endif

            if !sent {
                session.transferUserInfo([WCKeys.allTimeCount: all])
            }
        }
        #endif

        return .result()
    }
}
