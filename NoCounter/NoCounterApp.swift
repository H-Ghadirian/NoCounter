import SwiftUI
import SwiftData

@main
struct NoCounterApp: App {
    let container: ModelContainer

    init() {
        container = NoModelContainer.makeContainer()
        _ = PhoneWC.shared
        PhoneWC.shared.modelContext = container.mainContext
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
