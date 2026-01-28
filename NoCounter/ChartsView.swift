import SwiftUI
import SwiftData
import Charts

struct ChartsView: View {
    enum RangeKind: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
    }

    @Query(sort: \NoEvent.timestamp, order: .forward) private var events: [NoEvent]
    @State private var range: RangeKind = .week

    private let cal = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Picker("", selection: $range) {
                    ForEach(RangeKind.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 10)

                let summary = computeSummary(range: range, events: events)
                SummaryRow(summary: summary)
                    .padding(.horizontal, 16)

                BarCard(title: barTitle, points: barPoints(range: range, events: events))
                    .padding(.horizontal, 16)

                if range == .year {
                    HeatmapCard(title: "Year heatmap", cells: heatmapCells(events: events))
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 24)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("")
    }

    private var barTitle: String {
        switch range {
        case .day: return "Last 24h (by hour)"
        case .week: return "This week"
        case .month: return "This month"
        case .year: return "This year (by month)"
        }
    }

    // MARK: - Bar Points

    struct BarPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Int
        let date: Date
    }

    private func barPoints(range: RangeKind, events: [NoEvent]) -> [BarPoint] {
        let now = Date()

        switch range {
        case .day:
            // 24 hours, grouped by hour
            let start = cal.date(byAdding: .hour, value: -23, to: now) ?? now
            let bucketed = bucket(events: events, from: start, to: now, component: .hour)

            return bucketed.map { date, count in
                BarPoint(label: hourLabel(date), value: count, date: date)
            }.sorted { $0.date < $1.date }

        case .week:
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            let end = cal.date(byAdding: .day, value: 7, to: start) ?? now
            let bucketed = bucket(events: events, from: start, to: end, component: .day)

            return bucketed.map { date, count in
                BarPoint(label: weekdayLabel(date), value: count, date: date)
            }.sorted { $0.date < $1.date }

        case .month:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
            let end = cal.date(byAdding: .month, value: 1, to: start) ?? now
            let bucketed = bucket(events: events, from: start, to: end, component: .day)

            return bucketed.map { date, count in
                BarPoint(label: dayOfMonthLabel(date), value: count, date: date)
            }.sorted { $0.date < $1.date }

        case .year:
            let start = cal.date(from: cal.dateComponents([.year], from: now)) ?? now
            let end = cal.date(byAdding: .year, value: 1, to: start) ?? now
            let bucketed = bucket(events: events, from: start, to: end, component: .month)

            return bucketed.map { date, count in
                BarPoint(label: monthLabel(date), value: count, date: date)
            }.sorted { $0.date < $1.date }
        }
    }

    private func bucket(
        events: [NoEvent],
        from start: Date,
        to end: Date,
        component: Calendar.Component
    ) -> [Date: Int] {
        // Build all buckets first (so empty days show as 0)
        var buckets: [Date: Int] = [:]
        var cursor = cal.dateInterval(of: component, for: start)?.start ?? start

        while cursor < end {
            let key = cal.dateInterval(of: component, for: cursor)?.start ?? cursor
            buckets[key] = 0
            cursor = cal.date(byAdding: component, value: 1, to: cursor) ?? end
        }

        for e in events {
            guard e.timestamp >= start && e.timestamp < end else { continue }
            let key = cal.dateInterval(of: component, for: e.timestamp)?.start ?? e.timestamp
            buckets[key, default: 0] += 1
        }

        return buckets
    }

    // MARK: - Labels

    private func weekdayLabel(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "EEE"
        return f.string(from: d)
    }

    private func monthLabel(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "MMM"
        return f.string(from: d)
    }

    private func dayOfMonthLabel(_ d: Date) -> String {
        String(cal.component(.day, from: d))
    }

    private func hourLabel(_ d: Date) -> String {
        let h = cal.component(.hour, from: d)
        return "\(h)"
    }

    // MARK: - Summary

    struct Summary {
        let total: Int
        let avgPerDay: Double
        let bestDay: Int
        let allTime: Int
    }

    private func computeSummary(range: RangeKind, events: [NoEvent]) -> Summary {
        let now = Date()

        let (start, end, daysCount): (Date, Date, Double) = {
            switch range {
            case .day:
                let s = cal.date(byAdding: .day, value: -1, to: now) ?? now
                return (s, now, 1)
            case .week:
                let s = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
                let e = cal.date(byAdding: .day, value: 7, to: s) ?? now
                return (s, e, 7)
            case .month:
                let s = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
                let e = cal.date(byAdding: .month, value: 1, to: s) ?? now
                // approx days in month:
                let range = cal.range(of: .day, in: .month, for: now)?.count ?? 30
                return (s, e, Double(range))
            case .year:
                let s = cal.date(from: cal.dateComponents([.year], from: now)) ?? now
                let e = cal.date(byAdding: .year, value: 1, to: s) ?? now
                return (s, e, 365)
            }
        }()

        let inRange = events.filter { $0.timestamp >= start && $0.timestamp < end }
        let total = inRange.count

        // best day within range
        let perDay = bucket(events: inRange, from: start, to: end, component: .day)
        let best = perDay.values.max() ?? 0

        return Summary(
            total: total,
            avgPerDay: daysCount == 0 ? 0 : Double(total) / daysCount,
            bestDay: best,
            allTime: events.count
        )
    }

    // MARK: - Heatmap

    struct HeatCell: Identifiable {
        let id = UUID()
        let date: Date
        let level: Int // 0...4
        let count: Int
    }

    private func heatmapCells(events: [NoEvent]) -> [HeatCell] {
        let now = Date()
        // last 365 days
        let end = cal.startOfDay(for: now)
        let start = cal.date(byAdding: .day, value: -364, to: end) ?? end

        let counts = bucket(events: events, from: start, to: cal.date(byAdding: .day, value: 1, to: end) ?? end, component: .day)

        // map count -> level
        func level(for count: Int) -> Int {
            switch count {
            case 0: return 0
            case 1: return 1
            case 2...3: return 2
            case 4...6: return 3
            default: return 4
            }
        }

        return counts.keys.sorted().map { day in
            let c = counts[day] ?? 0
            return HeatCell(date: day, level: level(for: c), count: c)
        }
    }
}
