import WidgetKit
import SwiftUI

@main
struct widgetBundle: WidgetBundle {
    var body: some Widget {
        NoHomeWidget()
        NoLockWidget()
        NoLockControlWidget()
    }
}
