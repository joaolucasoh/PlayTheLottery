import SwiftUI

public struct LoadingOverlay<Content: View>: View {
    @Binding var isLoading: Bool
    let message: String
    let numbers: [Int]
    let size: CGFloat
    let speed: Double
    @ViewBuilder let content: () -> Content

    public init(isLoading: Binding<Bool>, message: String, numbers: [Int] = [1,7,13,22,33,45], size: CGFloat = 44, speed: Double = 0.5, @ViewBuilder content: @escaping () -> Content) {
        self._isLoading = isLoading
        self.message = message
        self.numbers = numbers
        self.size = size
        self.speed = speed
        self.content = content
    }

    public var body: some View {
        ZStack {
            content()
                .blur(radius: isLoading ? 4 : 0)
                .allowsHitTesting(!isLoading)
            if isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
                VStack(spacing: 12) {
                    LotteryBallsLoadingView(numbers: numbers, size: size, speed: speed)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(2)
            }
        }
    }
}

public extension View {
    func loadingOverlay(isLoading: Binding<Bool>, message: String, numbers: [Int] = [1,7,13,22,33,45], size: CGFloat = 44, speed: Double = 0.5) -> some View {
        LoadingOverlay(isLoading: isLoading, message: message, numbers: numbers, size: size, speed: speed) {
            self
        }
    }
}

#Preview {
    LoadingOverlay(isLoading: .constant(true), message: "Carregando...") {
        VStack { Text("Conteúdo") }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
    }
}
