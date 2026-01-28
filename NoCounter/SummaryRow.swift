import SwiftUI

struct SummaryRow: View {
    let summary: ChartsView.Summary

    var body: some View {
        HStack(spacing: 10) {
            StatCard(title: "This Range", value: "\(summary.total)")
            StatCard(title: "Avg / Day", value: String(format: "%.1f", summary.avgPerDay))
            StatCard(title: "Best Day", value: "\(summary.bestDay)")
            StatCard(title: "All Time", value: "\(summary.allTime)")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.headline.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
