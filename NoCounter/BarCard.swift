import SwiftUI
import Charts

struct BarCard: View {
    let title: String
    let points: [ChartsView.BarPoint]
    let range: ChartsView.RangeKind

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)

            Chart(points) { p in
                BarMark(
                    x: .value("X", p.date),
                    y: .value("Count", p.value)
                )
            }
            .chartXAxis {
                xAxis(for: range)
            }
            .frame(height: 180)
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @AxisContentBuilder
    private func xAxis(for range: ChartsView.RangeKind) -> some AxisContent {
        switch range {
        case .day:
            AxisMarks(values: .stride(by: .hour, count: 4)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
            }

        case .week:
            AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }

        case .month:
            AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day())
            }

        case .year:
            AxisMarks(values: .stride(by: .month, count: 2)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
    }
}
