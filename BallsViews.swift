import SwiftUI

// Shared balls components for use across the app
struct InlineBallsRowView: View {
    let numbers: [Int]
    var size: CGFloat
    var spacing: CGFloat
    var lineSpacing: CGFloat

    init(numbers: [Int], size: CGFloat = 36, spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.numbers = numbers
        self.size = size
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    init(numbersString: String, separator: String = "🍀", size: CGFloat = 36, spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        let parts = numbersString
            .components(separatedBy: separator)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let ints = parts.compactMap { Int($0) }
        self.init(numbers: ints, size: size, spacing: spacing, lineSpacing: lineSpacing)
    }

    var body: some View {
        let smallSetThreshold = 8
        if numbers.count <= smallSetThreshold {
            HStack(spacing: spacing) {
                ForEach(numbers.indices, id: \ .self) { idx in
                    InlineBallImage(number: numbers[idx], size: size)
                }
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        } else {
            let minItem = size
            let columns = [GridItem(.adaptive(minimum: minItem), spacing: spacing)]
            HStack {
                Spacer(minLength: 0)
                LazyVGrid(columns: columns, alignment: .center, spacing: lineSpacing) {
                    ForEach(numbers.indices, id: \ .self) { idx in
                        InlineBallImage(number: numbers[idx], size: size)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer(minLength: 0)
            }
        }
    }
}

struct InlineBallImage: View {
    let number: Int
    var size: CGFloat

    var body: some View {
        Image("ball_\(number)")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel(Text("Número \(number)"))
    }
}
