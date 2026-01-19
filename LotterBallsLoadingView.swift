import SwiftUI

public struct LotteryBallsLoadingView: View {
    private let numbers: [Int]
    private let size: CGFloat
    private let speed: Double
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = true

    public init(numbers: [Int] = [1, 7, 13, 22, 33, 45], size: CGFloat = 44, speed: Double = 0.5) {
        self.numbers = numbers
        self.size = size
        self.speed = speed
    }

    public var body: some View {
        HStack(spacing: 10) {
            ForEach(numbers.indices, id: \.self) { idx in
                let n = numbers[(idx + currentIndex) % numbers.count]
                Image("ball_\(n)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .opacity(opacity(for: idx))
                    .scaleEffect(scale(for: idx))
                    .animation(.easeInOut(duration: speed), value: currentIndex)
            }
        }
        .onAppear { startAnimation() }
        .onDisappear { isAnimating = false }
        .accessibilityLabel(Text("Carregando"))
    }

    private func opacity(for idx: Int) -> Double {
        idx == 0 ? 1.0 : (idx == 1 ? 0.75 : (idx == 2 ? 0.5 : 0.35))
    }

    private func scale(for idx: Int) -> CGFloat {
        idx == 0 ? 1.0 : (idx == 1 ? 0.92 : (idx == 2 ? 0.86 : 0.82))
    }

    private func startAnimation() {
        isAnimating = true
        Task { @MainActor in
            while isAnimating {
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
                currentIndex = (currentIndex + 1) % numbers.count
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.05).ignoresSafeArea()
        LotteryBallsLoadingView()
    }
}
