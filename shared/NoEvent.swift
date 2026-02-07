import Foundation
import SwiftData

@Model
final class NoEvent {
    var timestamp: Date

    init(timestamp: Date = .now) {
        self.timestamp = timestamp
    }
}
