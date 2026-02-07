import Foundation
import SwiftData

enum NoModelContainer {
    private static let appGroupID = "group.me.HamedGh.NoCounter"

    static func makeContainer() -> ModelContainer {
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            let storeURL = groupURL.appendingPathComponent("NoCounter.store")
            let config = ModelConfiguration(url: storeURL)
            return try! ModelContainer(for: NoEvent.self, configurations: config)
        }

        return try! ModelContainer(for: NoEvent.self)
    }
}
