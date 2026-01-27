import SwiftUI

@main
struct NoCounterWatchApp: App {
    init() {
        _ = WatchWC.shared
    }

    var body: some Scene {
        WindowGroup {
            WatchCounterView()
        }
    }
}
