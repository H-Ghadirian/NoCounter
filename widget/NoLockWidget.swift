import AppIntents
import WidgetKit
import SwiftUI

struct NoLockWidget: Widget {
    let kind: String = "NoLockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NoAccessoryView(count: entry.count)
        }
        .configurationDisplayName("No (Lock Screen)")
        .description("Today’s No count.")
        .supportedFamilies([
            .accessoryRectangular,
        ])
    }
}

struct NoAccessoryView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text("\(count)")
                .font(.system(.title3, design: .rounded).weight(.semibold))

            Text("NO")
                .foregroundStyle(.white)
                .font(.system(size: 20, weight: .bold))
        }
    }
}
