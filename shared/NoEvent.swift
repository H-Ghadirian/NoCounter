import Foundation
import SwiftData

@Model
final class NoEvent {
    var timestamp: Date = Date.now

    init(timestamp: Date = Date.now) {
        self.timestamp = timestamp
    }
}
