import SwiftUI

public struct BallsRowView: View {
    public let numbers: [Int]
    public var size: CGFloat = 36
    public var spacing: CGFloat = 6
    public var lineSpacing: CGFloat = 6

    public init(numbers: [Int], size: CGFloat = 36, spacing: CGFloat = 6, lineSpacing: CGFloat = 6) {
        self.numbers = numbers
        self.size = size
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    public init(numbersString: String, separator: String = "🍀", size: CGFloat = 36, spacing: CGFloat = 6, lineSpacing: CGFloat = 6) {
        let parts = numbersString
            .components(separatedBy: separator)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let ints = parts.compactMap { Int($0) }
        self.init(numbers: ints, size: size, spacing: spacing, lineSpacing: lineSpacing)
    }

    public var body: some View {
        FlowLayout(spacing: spacing, lineSpacing: lineSpacing) {
            ForEach(numbers.indices, id: \.self) { idx in
                let n = numbers[idx]
                BallImage(number: n, size: size)
            }
        }
    }
}

public struct BallImage: View {
    public let number: Int
    public var size: CGFloat

    public init(number: Int, size: CGFloat = 36) {
        self.number = number
        self.size = size
    }

    private var imageName: String { "ball_\(number)" }

    public var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel(Text("Número \(number)"))
    }
}

// Simple flow layout that wraps items onto multiple lines.
public struct FlowLayout<Content: View>: View {
    var spacing: CGFloat
    var lineSpacing: CGFloat
    @ViewBuilder var content: Content

    public init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(FlowLayoutRoot(spacing: spacing, lineSpacing: lineSpacing)) {
            content
        }
    }

    private struct FlowLayoutRoot: _VariadicView_UnaryViewRoot {
        var spacing: CGFloat
        var lineSpacing: CGFloat

        func body(children: _VariadicView.Children) -> some View {
            FlowLayoutImpl(spacing: spacing, lineSpacing: lineSpacing) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    child
                }
            }
        }
    }
}

public struct FlowLayoutImpl<Content: View>: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat
    var content: () -> Content

    public init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }

        return CGSize(width: maxWidth, height: y + lineHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var lineStart = 0

        func placeLine(from start: Int, to end: Int, at y: CGFloat) {
            var currentX: CGFloat = 0
            for i in start..<end {
                let sub = subviews[i]
                let size = sub.sizeThatFits(.unspecified)
                let origin = CGPoint(x: bounds.minX + currentX, y: bounds.minY + y)
                sub.place(at: origin, proposal: ProposedViewSize(size))
                currentX += size.width + spacing
            }
        }

        for (i, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                placeLine(from: lineStart, to: i, at: y)
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
                lineStart = i
            }
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }

        placeLine(from: lineStart, to: subviews.count, at: y)
    }
}

#Preview("Com [Int]") {
    BallsRowView(numbers: [1, 5, 12, 33, 45, 60, 72, 90], size: 40)
        .padding()
}

#Preview("Com String com trevo") {
    BallsRowView(numbersString: "12 🍀 7 🍀 33 🍀 1", size: 40)
        .padding()
}
