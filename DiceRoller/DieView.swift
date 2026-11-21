import SwiftUI

/// One die face, drawn with dots like a real die.
struct DieView: View {
    let value: Int

    /// Which of the nine spots (a 3 by 3 grid, counted left to right, top to bottom) show a dot.
    private static let spots: [Int: Set<Int>] = [
        1: [4],
        2: [0, 8],
        3: [0, 4, 8],
        4: [0, 2, 6, 8],
        5: [0, 2, 4, 6, 8],
        6: [0, 2, 3, 5, 6, 8],
    ]

    var body: some View {
        GeometryReader { box in
            let side = min(box.size.width, box.size.height)
            let dot = side * 0.17
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.2, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.18), radius: side * 0.06, y: side * 0.03)
                VStack(spacing: side * 0.09) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: side * 0.09) {
                            ForEach(0..<3, id: \.self) { column in
                                Circle()
                                    .fill(.black)
                                    .frame(width: dot, height: dot)
                                    .opacity(Self.spots[value, default: []].contains(row * 3 + column) ? 1 : 0)
                            }
                        }
                    }
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel("Die showing \(value)")
    }
}

#Preview {
    DieView(value: 5).frame(width: 120).padding()
}
