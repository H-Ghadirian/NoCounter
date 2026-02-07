import SwiftUI

struct WatchCounterView: View {
    @State private var count = NoStore.count()
    @State private var lock: Bool = false
    @State private var pollTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 10) {
            Text("\(count)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()

            Button {
                let t = CFAbsoluteTimeGetCurrent()
                print("View - Button sendAdd pressed at \(t)")
                WKInterfaceDevice.current().play(.click)

                lock = true
                DispatchQueue.main.async { count += 1 }
                DispatchQueue.global().async {
                    WatchWC.shared.sendAdd { newCount in
                        print("View - WatchWC.shared.sendAdd \(String(describing: newCount))")
    //                    if let newCount { DispatchQueue.main.async { count = newCount } }
                    }
                }
            } label: {
                Text("NO")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }

            Button {
                print("View - Button sendUndo pressed")
                lock = true

                count -= 1
                WatchWC.shared.sendUndo { newCount in
                    print("View - WatchWC.shared.sendUndo \(String(describing: newCount))")
//                    if let newCount { DispatchQueue.main.async { count = newCount } }
                }
            } label: {
                Text("Undo").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(count == 0)
        }
//        .padding(.horizontal, 8)
        .onAppear {
            startPolling()

            let t = CFAbsoluteTimeGetCurrent()
            print("View - onAppear called \(t)")
            WKInterfaceDevice.current().play(.click)
            WatchWC.shared.requestState { newCount in
                print("View - requestState \(String(describing: newCount))")
                if let newCount { DispatchQueue.main.async { count = newCount } }
            }
        }
        .onDisappear {
            stopPolling()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .watchCountDidUpdate)
        ) { n in
            if let v = n.object as? Int {
                print("View - onReceive watchCountDidUpdate")
                DispatchQueue.main.async {
                    if !lock {
                        count = v
                        print("View - onReceive count = v")
                    }
                    lock = false
                }
            }
        }
    }

    private func startPolling() {
        stopPolling()
        pollTask = Task { @MainActor in
            while !Task.isCancelled {
                WatchWC.shared.requestState { newCount in
                    if let newCount {
                        DispatchQueue.main.async { count = newCount }
                    }
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }

    private func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }
}

#Preview {
    WatchCounterView()
}
