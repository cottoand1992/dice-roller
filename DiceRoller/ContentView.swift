import SwiftUI

/// One finished roll, kept for the history list.
struct Roll: Identifiable {
    let id = UUID()
    let dice: [Int]
    var total: Int { dice.reduce(0, +) }
}

struct ContentView: View {
    @State private var diceCount = 2
    @State private var dice = [3, 4]
    @State private var history: [Roll] = []
    @State private var spin = 0.0

    /// Up to three dice per row, centered.
    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(96), spacing: 18), count: min(dice.count, 3))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Number of dice", selection: $diceCount) {
                    ForEach(1...6, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: diceCount) { _, _ in roll() }

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(dice.indices, id: \.self) { index in
                        DieView(value: dice[index])
                            .rotationEffect(.degrees(spin))
                    }
                }
                .frame(maxHeight: .infinity)

                Text("Total: \(dice.reduce(0, +))")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Button(action: roll) {
                    Label("Roll", systemImage: "dice.fill")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)

                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last rolls").font(.headline)
                        ForEach(history.prefix(5)) { roll in
                            HStack {
                                Text(roll.dice.map(String.init).joined(separator: "  "))
                                    .monospacedDigit()
                                Spacer()
                                Text("\(roll.total)").bold().monospacedDigit()
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .navigationTitle("Dice Roller")
            .background(Color(.systemGroupedBackground))
        }
    }

    /// Rolls every die, gives the dice a full turn, and saves the result at the top of the history.
    private func roll() {
        withAnimation(.spring(duration: 0.5)) {
            dice = (0..<diceCount).map { _ in Int.random(in: 1...6) }
            spin += 360
        }
        history.insert(Roll(dice: dice), at: 0)
        if history.count > 20 { history.removeLast() }
    }
}

#Preview {
    ContentView()
}
