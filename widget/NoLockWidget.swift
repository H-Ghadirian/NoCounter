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
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct NoAccessoryView: View {
    let count: Int
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Text("\(count)")
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                    Text("NO")
                        .font(.caption2.weight(.semibold))
                        .opacity(0.9)
                }
            }

        case .accessoryRectangular:
            ZStack {
                AccessoryWidgetBackground()
                HStack(spacing: 8) {
                    Image(systemName: "nosign")
                        .font(.body.weight(.semibold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Today")
                            .font(.caption.weight(.medium))
                            .opacity(0.9)
                        Text("\(count)")
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
            }

        case .accessoryInline:
            Text("No \(count)")

        default:
            Text("\(count)")
        }
    }
}
