import SwiftUI

struct HeatmapCard: View {
    let title: String
    let cells: [ChartsView.HeatCell]

    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            // simple GitHub-like grid: 7 columns (days), rows flow
            LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                ForEach(cells) { cell in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(color(for: cell.level))
                        .frame(width: 12, height: 12)
                        .accessibilityLabel("\(cell.count) on \(cell.date.formatted(date: .abbreviated, time: .omitted))")
                }
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func color(for level: Int) -> Color {
        // neutral -> stronger (GitHub-ish). Uses system colors so it looks good in dark mode too.
        switch level {
        case 0: return Color.secondary.opacity(0.15)
        case 1: return Color.green.opacity(0.30)
        case 2: return Color.green.opacity(0.45)
        case 3: return Color.green.opacity(0.65)
        default: return Color.green.opacity(0.85)
        }
    }
}
