import SwiftUI
import SwiftData
import CloudKit

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoEvent.timestamp, order: .reverse) private var events: [NoEvent]
    @State private var iCloudStatusMessage: String?

    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("Counter", systemImage: "hand.raised.fill") }

            ChartsView()
                .tabItem { Label("Charts", systemImage: "chart.bar.fill") }
        }
        .overlay(alignment: .top) {
            if let message = iCloudStatusMessage {
                HStack(spacing: 8) {
                    Image(systemName: "icloud.slash")
                    Text(message)
                        .font(.footnote.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.9), in: Capsule())
                .padding(.top, 12)
            }
        }
        .onAppear {
            if PhoneWC.shared.modelContext == nil {
                PhoneWC.shared.modelContext = modelContext
            }
        }
        .onChange(of: events.count) { _, _ in
            PhoneWC.shared.syncAfterLocalChange()
        }
        .task {
            await updateICloudStatus()
        }
    }

    @MainActor
    private func updateICloudStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                iCloudStatusMessage = nil
            case .noAccount:
                iCloudStatusMessage = "Sign in to iCloud to enable restore."
            case .restricted:
                iCloudStatusMessage = "iCloud is restricted on this device."
            case .couldNotDetermine:
                iCloudStatusMessage = "iCloud status couldn't be determined."
            case .temporarilyUnavailable:
                iCloudStatusMessage = "iCloud is temporarily unavailable."
            @unknown default:
                iCloudStatusMessage = "iCloud status unavailable."
            }
        } catch {
            iCloudStatusMessage = "iCloud status couldn't be checked."
        }
    }
}

