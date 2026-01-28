import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("Counter", systemImage: "hand.raised.fill") }

            ChartsView()
                .tabItem { Label("Charts", systemImage: "chart.bar.fill") }
        }
        .onAppear {
            PhoneWC.shared.modelContext = modelContext
        }
    }
}
