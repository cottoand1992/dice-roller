import SwiftUI

/// One finished roll, kept for the history card.
struct Roll: Identifiable {
    let id = UUID()
    let dice: [Int]
    var total: Int { dice.reduce(0, +) }
}

struct ContentView: View {
    /// How many past rolls the history card shows. The card always keeps room for this many
    /// rows, so nothing on the screen moves when a roll comes in.
    private static let historyRows = 4

    @State private var diceCount = 2
    @State private var dice = ContentView.randomDice(2)
    @State private var history: [Roll] = []
    @State private var spin = 0.0
    @State private var rollsMade = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Number of dice", selection: $diceCount) {
                    ForEach(1...6, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: diceCount) { _, _ in roll() }

                DiceBoard(dice: dice, spin: spin)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text("Total: \(dice.reduce(0, +))")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .contentTransition(.numericText())

                HistoryCard(history: history, rows: Self.historyRows)

                Button(action: roll) {
                    Label("Roll", systemImage: "dice.fill")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .navigationTitle("Dice Roller")
            .background(Color(.systemGroupedBackground))
            .sensoryFeedback(.impact, trigger: rollsMade)
        }
        // Very large text sizes would push the Roll button off the screen.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private static func randomDice(_ count: Int) -> [Int] {
        (0..<count).map { _ in Int.random(in: 1...6) }
    }

    /// Rolls every die, gives the dice a full turn, and puts the result at the top of the history.
    private func roll() {
        let newDice = Self.randomDice(diceCount)
        withAnimation(reduceMotion ? nil : .spring(duration: 0.5)) {
            dice = newDice
            if !reduceMotion { spin += 360 }
        }
        history.insert(Roll(dice: newDice), at: 0)
        if history.count > Self.historyRows { history.removeLast() }
        rollsMade += 1
        AccessibilityNotification.Announcement("Rolled \(newDice.reduce(0, +))").post()
    }
}

/// The dice, centered. One to three sit in one row, four make two rows of two,
/// five and six put three on top. The dice shrink to fit a small screen.
struct DiceBoard: View {
    let dice: [Int]
    let spin: Double
    private let gap: CGFloat = 18

    /// Positions in `dice`, split into rows.
    private var rows: [[Int]] {
        let all = Array(dice.indices)
        switch all.count {
        case ...3: return [all]
        case 4: return [Array(all[..<2]), Array(all[2...])]
        default: return [Array(all[..<3]), Array(all[3...])]
        }
    }

    var body: some View {
        GeometryReader { box in
            let widest = CGFloat(rows.map(\.count).max() ?? 1)
            let fitsAcross = (box.size.width - gap * (widest - 1)) / widest
            let fitsDown = (box.size.height - gap * CGFloat(rows.count - 1)) / CGFloat(rows.count)
            let side = max(36, min(110, fitsAcross, fitsDown))
            VStack(spacing: gap) {
                ForEach(rows.indices, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(rows[row], id: \.self) { index in
                            DieView(value: dice[index])
                                .frame(width: side, height: side)
                                .rotationEffect(.degrees(spin))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// The last few rolls, newest on top. Empty rows keep their space so the card never changes size.
struct HistoryCard: View {
    let history: [Roll]
    let rows: Int
    @ScaledMetric private var rowHeight: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Last rolls")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)
            ForEach(0..<rows, id: \.self) { index in
                Group {
                    if index < history.count {
                        HistoryRow(roll: history[index], isNewest: index == 0)
                    } else if index == 0 {
                        Text("No rolls yet. Tap Roll to start.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, minHeight: rowHeight, maxHeight: rowHeight, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// One past roll: a small picture of each die, then the total.
struct HistoryRow: View {
    let roll: Roll
    let isNewest: Bool

    var body: some View {
        HStack(spacing: 6) {
            ForEach(roll.dice.indices, id: \.self) { index in
                Image(systemName: "die.face.\(roll.dice[index]).fill")
                    .font(.title3)
            }
            Spacer()
            Text("\(roll.total)")
                .font(.body.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(isNewest ? .primary : .secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rolled \(roll.dice.map(String.init).joined(separator: ", ")), total \(roll.total)")
    }
}

#Preview {
    ContentView()
}
