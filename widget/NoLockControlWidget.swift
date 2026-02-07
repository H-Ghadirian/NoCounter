import WidgetKit
import SwiftUI

struct NoLockControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "NoLockControl") {
            ControlWidgetButton(action: IncrementNoCountIntent()) {
                Label("No +1", systemImage: "plus.circle")
            }
        }
        .displayName("No Counter")
        .description("Increment the No counter.")
    }
}
