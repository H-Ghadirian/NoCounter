import WidgetKit
import SwiftUI
import AppIntents

struct NoHomeWidget: Widget {
    let kind: String = "NoHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NoHomeView(count: entry.count)
        }
        .configurationDisplayName("No Counter")
        .description("See the No count and adjust it.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
        ])
    }
}

struct NoHomeView: View {
    let count: Int
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("NO")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.primary)

            Text("\(count)")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                Button(intent: DecrementNoCountIntent()) {
                    Label("-1", systemImage: "minus.circle.fill")
                }
                Button(intent: IncrementNoCountIntent()) {
                    Label("+1", systemImage: "plus.circle.fill")
                }
            }
            .labelStyle(.iconOnly)
            .font(.system(size: 18, weight: .semibold))
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color.clear
        }
        .padding()
    }
}
