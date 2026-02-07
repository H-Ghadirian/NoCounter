import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoEvent.timestamp, order: .reverse) private var events: [NoEvent]

    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("Counter", systemImage: "hand.raised.fill") }

            ChartsView()
                .tabItem { Label("Charts", systemImage: "chart.bar.fill") }
        }
        .onAppear {
            if PhoneWC.shared.modelContext == nil {
                PhoneWC.shared.modelContext = modelContext
            }
        }
        .onChange(of: events.count) { _ in
            PhoneWC.shared.syncAfterLocalChange()
        }
    }
}
