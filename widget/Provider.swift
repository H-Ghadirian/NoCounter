import Foundation
import WidgetKit

struct Entry: TimelineEntry {
    let date: Date
    let count: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        .init(date: .now, count: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(.init(date: .now, count: NoStore.count()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = Entry(date: .now, count: NoStore.count())
        completion(Timeline(entries: [entry], policy: .never))
    }
}
