import SwiftUI
import SwiftData

struct CounterView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoEvent.timestamp, order: .reverse) private var events: [NoEvent]

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)

            Text("NO Counter")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text("\(events.count)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("times I said NO")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                modelContext.insert(NoEvent())
                NoStore.increment()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("NO")
                        .font(.system(size: 20, weight: .bold))
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background {
                    Capsule()
                        .fill(colorScheme == .dark
                              ? Color(uiColor: .secondarySystemBackground)
                              : Color.black)
                }
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.12), lineWidth: 3)
                }
            }
            .tint(.primary)
            .padding(.horizontal, 20)

            Button {
                undoLast()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .frame(height: 44)
                    .frame(maxWidth: 180)
            }
            .buttonStyle(.bordered)
            .disabled(events.isEmpty)
            .padding(.bottom, 18)

            Spacer(minLength: 8)
        }
        .padding(.top, 24)
    }

    private func undoLast() {
        guard let last = events.first else { return }
        modelContext.delete(last)
        NoStore.decrement()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
