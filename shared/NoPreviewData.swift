import Foundation
import SwiftData

enum NoPreviewData {
    @MainActor static func container(eventCount: Int = 12) -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: NoEvent.self, configurations: config)
        let ctx = container.mainContext
        let now = Date()

        for index in 0..<eventCount {
            let date = Calendar.current.date(byAdding: .hour, value: -(index * 6), to: now) ?? now
            ctx.insert(NoEvent(timestamp: date))
        }

        return container
    }
}
