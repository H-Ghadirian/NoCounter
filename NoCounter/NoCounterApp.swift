import SwiftUI
import SwiftData

@main
struct NoCounterApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: NoEvent.self)
    }
}
