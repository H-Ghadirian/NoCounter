import SwiftUI

struct WatchCounterView: View {
    @State private var count = NoStore.count()

    var body: some View {
        VStack(spacing: 10) {
            Text("\(count)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()

            Button {
                print("Button sendAdd pressed")
                WatchWC.shared.sendAdd { newCount in
                    print("WatchWC.shared.sendAdd \(String(describing: newCount))")
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
                print("Button sendUndo pressed")
                WatchWC.shared.sendUndo { newCount in
                    print("WatchWC.shared.sendUndo \(String(describing: newCount))")
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
                print("requestState \(String(describing: newCount))")
                if let newCount { DispatchQueue.main.async { count = newCount } }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .watchCountDidUpdate)) { n in
            if let v = n.object as? Int {
                DispatchQueue.main.async { count = v }
            }
        }
    }
}

#Preview {
    WatchCounterView()
}
