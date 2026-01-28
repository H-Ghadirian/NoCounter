import SwiftUI

struct WatchCounterView: View {
    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 10) {
            Text("\(count)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()

            Button {
                WatchWC.shared.sendAdd { newCount in
                    if let newCount { DispatchQueue.main.async { count = newCount } }
                }
            } label: {
                Text("NO")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)

            Button {
                WatchWC.shared.sendUndo { newCount in
                    if let newCount { DispatchQueue.main.async { count = newCount } }
                }
            } label: {
                Text("Undo").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(count == 0)
        }
        .padding(.horizontal, 8)
        .onAppear {
            WatchWC.shared.requestState { newCount in
                if let newCount { DispatchQueue.main.async { count = newCount } }
            }
        }
    }
}

#Preview {
    WatchCounterView()
}
