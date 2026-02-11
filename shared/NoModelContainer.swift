import Foundation
import SwiftData

enum NoModelContainer {
    private static let appGroupID = "group.me.HamedGh.NoCounter"
    private static let legacyStoreName = "NoCounter.store"

    static func makeContainer() -> ModelContainer {
        let cloudConfig = ModelConfiguration(
            groupContainer: .none,
            cloudKitDatabase: .automatic
        )

        do {
            let container = try ModelContainer(for: NoEvent.self, configurations: cloudConfig)
            Task { @MainActor in
                migrateLegacyStoreIfNeeded(into: container)
            }
            return container
        } catch {
            #if DEBUG
            print("NoModelContainer: CloudKit config failed, falling back. Error: \(error)")
            #endif

            if let legacyURL = legacyStoreURL() {
                let legacyConfig = ModelConfiguration(url: legacyURL, cloudKitDatabase: .none)
                if let legacyContainer = try? ModelContainer(
                    for: NoEvent.self,
                    configurations: legacyConfig
                ) {
                    return legacyContainer
                }
            }

            return try! ModelContainer(for: NoEvent.self)
        }
    }

    @MainActor
    private static func migrateLegacyStoreIfNeeded(into container: ModelContainer) {
        guard let legacyURL = legacyStoreURL() else { return }
        guard FileManager.default.fileExists(atPath: legacyURL.path) else { return }

        let ctx = container.mainContext
        let currentCount = (try? ctx.fetchCount(FetchDescriptor<NoEvent>())) ?? 0
        guard currentCount == 0 else { return }

        let legacyConfig = ModelConfiguration(
            url: legacyURL,
            cloudKitDatabase: .none
        )
        guard let legacyContainer = try? ModelContainer(
            for: NoEvent.self,
            configurations: legacyConfig
        ) else { return }

        let legacyEvents = (try? legacyContainer.mainContext.fetch(
            FetchDescriptor<NoEvent>()
        )) ?? []
        guard !legacyEvents.isEmpty else { return }

        legacyEvents.forEach { ctx.insert(NoEvent(timestamp: $0.timestamp)) }
        try? ctx.save()
    }

    private static func legacyStoreURL() -> URL? {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            return nil
        }
        return groupURL.appendingPathComponent(legacyStoreName)
    }
}
