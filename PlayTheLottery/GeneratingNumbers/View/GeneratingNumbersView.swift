import SwiftUI

// Inline balls components to avoid missing-type errors
private struct InlineBallsRowView: View {
    let numbers: [Int]
    var size: CGFloat = 36
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

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
        // Threshold: for small sets, render in a single centered row
        let smallSetThreshold = 8
        if numbers.count <= smallSetThreshold {
            HStack(spacing: spacing) {
                ForEach(numbers.indices, id: \.self) { idx in
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
                    ForEach(numbers.indices, id: \.self) { idx in
                        InlineBallImage(number: numbers[idx], size: size)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer(minLength: 0)
            }
        }
    }
}

private struct InlineBallImage: View {
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

struct GeneratingNumbersView: View {
    
    @StateObject var viewModel: GeneratingNumbersViewModel
    
    init(viewModel: GeneratingNumbersViewModel = GeneratingNumbersViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var alertMessage = ""
    @State private var showCustomAlert = false
    @State private var isShareButtonEnabled = false
    @State private var selectedGameType = ""
    @State private var selectedGameConfig: GameConfig?
    @State private var highlightedItem: String? = nil
    @State private var pressedItem: String? = nil
    
    // Novo estado para a quantidade de números da Mega-Sena
    @State private var megaSenaNumbersAmount = 6
    
    // Novo estado para a quantidade de números da Lotofacil
    @State private var lotofacilNumbersAmount = 15
    
    // Novo estado para a quantidade de números da Quina
    @State private var quinaNumbersAmount = 5
    
    struct GameConfig {
        let name: String
        let totalNumbers: Int
        let maxNumber: Int
    }
    
    func randomLottoNumberGenerator(total: Int, maxNumber: Int) -> [String] {
        var numbers: Set<Int> = []
        while numbers.count < total {
            let randomNumber = Int.random(in: 1...maxNumber)
            numbers.insert(randomNumber)
        }
        let sortedNumbers = numbers.sorted()
        return sortedNumbers.map { String(format: "%02d", $0) }
    }
    
    let gameConfigs = [
        GameConfig(name: "Mega-Sena", totalNumbers: 6, maxNumber: 60),
        GameConfig(name: "Lotofacil", totalNumbers: 15, maxNumber: 25),
        GameConfig(name: "Quina", totalNumbers: 5, maxNumber: 80),
        GameConfig(name: "Lotomania", totalNumbers: 50, maxNumber: 100)
    ]
    
    func colorForGame(_ name: String) -> Color {
        switch name {
        case "Mega-Sena":
            return Color.green
        case "Lotofacil":
            return Color.purple
        case "Quina":
            return Color.blue
        case "Lotomania":
            return Color.orange
        default:
            return Color.gray
        }
    }
    
    func generateNumbersForSelectedGame() {
        guard let config = selectedGameConfig else { return }
        // Seleciona a quantidade customizada baseada no jogo selecionado
        let totalNumbersToGenerate: Int
        switch config.name {
        case "Mega-Sena":
            totalNumbersToGenerate = megaSenaNumbersAmount
        case "Lotofacil":
            totalNumbersToGenerate = lotofacilNumbersAmount
        case "Quina":
            totalNumbersToGenerate = quinaNumbersAmount
        default:
            totalNumbersToGenerate = config.totalNumbers
        }
        let generatedNumbers = randomLottoNumberGenerator(total: totalNumbersToGenerate, maxNumber: config.maxNumber)
        alertMessage = setToString(set: generatedNumbers)
        selectedGameType = config.name
        isShareButtonEnabled = true
    }
    
    func setToString(set: [String]) -> String {
        return set.joined(separator: " 🍀 ")
    }
    
    func shareViaWhatsApp(gameType: String, message: String) {
        let formattedMessage = "Os números gerados para \(gameType) foram: \(message)"
        let urlWhats = "whatsapp://send?text=\(formattedMessage)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                isShareButtonEnabled = false
            } else {
                print("WhatsApp não está instalado.")
            }
        }
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                Text("Escolha para qual jogo deseja os números🤞🏽🍀")
                    .font(.title)
                    .dynamicTypeSize(.medium ... .accessibility3)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.7)
                    .lineLimit(3)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                    ForEach(gameConfigs, id: \.name) { config in
                        VStack {
                            Image("\(config.name.lowercased())-button")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: .infinity)
                                .padding(12)
                            Spacer(minLength: 4)
                            Text(config.name)
                                .dynamicTypeSize(.medium ... .accessibility3)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.black)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .scaleEffect(0.8)
                        .padding(8)
                        .background(
                            Group {
                                if highlightedItem == config.name {
                                    colorForGame(config.name).opacity(0.15)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .cornerRadius(12)
                        .scaleEffect(pressedItem == config.name ? 0.96 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 280, damping: 8), value: pressedItem)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pressedItem = config.name
                            highlightedItem = config.name
                            selectedGameConfig = config
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                generateNumbersForSelectedGame()
                                showCustomAlert = true
                                highlightedItem = nil
                                pressedItem = nil
                            }
                        }
                        .animation(.easeInOut(duration: 0.15), value: highlightedItem)
                    }
                }
                
//                HStack(spacing: 20) {
//                    // Botão "Apostar" só aparece se a região for BR e o jogo selecionado for Mega-Sena
//                    if Locale.current.regionCode == "BR" {
//                        Button(action: {
//                            if let url = URL(string: "loterias://caixa") {
//                                if UIApplication.shared.canOpenURL(url) {
//                                    UIApplication.shared.open(url)
//                                } else {
//                                    if let appStoreUrl = URL(string: "https://apps.apple.com/br/app/loterias-caixa/id1436530324?l=en-GB") {
//                                        UIApplication.shared.open(appStoreUrl)
//                                    }
//                                }
//                            }
//                        }) {
//                            Text("Apostar")
//                                .dynamicTypeSize(.medium ... .accessibility3)
//                                .minimumScaleFactor(0.7)
//                                .lineLimit(1)
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .frame(width: 120)
//                                .padding()
//                                .background(Color.blue)
//                                .cornerRadius(10)
//                        }
//                    }
//                }
                .sheet(isPresented: $showCustomAlert) {
                    VStack(spacing: 20) {
                        Text("Números gerados para ")
                            .dynamicTypeSize(.medium ... .accessibility3)
                            .minimumScaleFactor(0.7)
                            .lineLimit(2)
                            .font(.title)
                            .foregroundColor(.black)
                        Text("\(selectedGameType):")
                            .dynamicTypeSize(.medium ... .accessibility3)
                            .minimumScaleFactor(0.7)
                            .lineLimit(2)
                            .font(.title.bold())
                            .foregroundColor(.black)
                        
                        if selectedGameType == "Mega-Sena" {
                            NumberAmountSelector(label: "Quantidade de números:", value: $megaSenaNumbersAmount, range: 6...20)
                        }
                        
                        if selectedGameType == "Lotofacil" {
                            NumberAmountSelector(label: "Quantidade de números:", value: $lotofacilNumbersAmount, range: 15...20)
                        }
                        
                        if selectedGameType == "Quina" {
                            NumberAmountSelector(label: "Quantidade de números:", value: $quinaNumbersAmount, range: 5...15)
                        }
                        
                        InlineBallsRowView(numbersString: alertMessage, size: 44, spacing: 8, lineSpacing: 10)
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        HStack {
                            Button("Gerar") {
                                generateNumbersForSelectedGame()
                            }
                            .dynamicTypeSize(.medium ... .accessibility3)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            // ✅ Botão Compartilhar — só aparece se não for iPad
                            if UIDevice.current.userInterfaceIdiom != .pad {
                                Button("Compartilhar") {
                                    shareViaWhatsApp(gameType: selectedGameType, message: alertMessage)
                                }
                                .dynamicTypeSize(.medium ... .accessibility3)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .disabled(!isShareButtonEnabled)
                            }
                            
                            Button("Voltar") {
                                showCustomAlert = false
                            }
                            .dynamicTypeSize(.medium ... .accessibility3)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    .padding()
                    .background(Color.white)
                    .preferredColorScheme(.light)
                    .onAppear {
                        if alertMessage.isEmpty {
                            generateNumbersForSelectedGame()
                        }
                    }
                    .onDisappear {
                        highlightedItem = nil
                    }
                }
            }
        }
    }
}

struct NumberAmountSelector: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(label)
                .font(.headline)
                .dynamicTypeSize(.medium ... .accessibility3)
                .minimumScaleFactor(0.7)
                .foregroundColor(Color(red: 0.22, green: 0.28, blue: 0.38))
                .frame(maxWidth: .infinity, alignment: .center)
            HStack(spacing: 16) {
                Button(action: {
                    if value > range.lowerBound { value -= 1 }
                }) {
                    Text("-")
                        .dynamicTypeSize(.medium ... .accessibility3)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 44, height: 44, alignment: .center)
                        .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                        )
                        .opacity(value == range.lowerBound ? 0.3 : 1.0)
                }
                .disabled(value == range.lowerBound)
                Text("\(value)")
                    .dynamicTypeSize(.medium ... .accessibility3)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 44, height: 44, alignment: .center)
                    .foregroundColor(Color(red: 0.22, green: 0.28, blue: 0.38))
                    .frame(minWidth: 36)
                    .padding(.horizontal, 6)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74)),
                        alignment: .bottom
                    )
                Button(action: {
                    if value < range.upperBound { value += 1 }
                }) {
                    Text("+")
                        .dynamicTypeSize(.medium ... .accessibility3)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 44, height: 44, alignment: .center)
                        .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                        )
                        .opacity(value == range.upperBound ? 0.3 : 1.0)
                }
                .disabled(value == range.upperBound)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 6)
        .padding(.bottom, 10)
    }
}

#Preview {
    GeneratingNumbersView(viewModel: GeneratingNumbersViewModel())
}

