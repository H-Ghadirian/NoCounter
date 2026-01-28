import SwiftUI
import Charts

struct BarCard: View {
    let title: String
    let points: [ChartsView.BarPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Chart(points) { p in
                BarMark(
                    x: .value("Label", p.label),
                    y: .value("Count", p.value)
                )
            }
            .frame(height: 180)
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
