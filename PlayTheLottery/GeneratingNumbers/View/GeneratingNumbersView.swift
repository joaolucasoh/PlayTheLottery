import SwiftUI

struct GeneratingNumbersView: View {
    
    @State private var alertMessage = ""
    @State private var showCustomAlert = false
    @State private var isShareButtonEnabled = false
    @State private var selectedGameType = ""
    @State private var selectedGameConfig: GameConfig?
    
    // Novo estado para a quantidade de números da Mega-Sena
    @State private var megaSenaNumbersAmount = 6
    
    // Novo estado para a quantidade de números da Lotofacil
    @State private var lotofacilNumbersAmount = 15
    
    // Novo estado para a quantidade de números da Quina
    @State private var quinaNumbersAmount = 5
    
    @ObservedObject var viewModel: GeneratingNumbersViewModel
    
    struct GameConfig {
        let name: String
        let totalNumbers: Int
        let maxNumber: Int
    }
    
    let gameConfigs = [
        GameConfig(name: "Mega-Sena", totalNumbers: 6, maxNumber: 60),
        GameConfig(name: "Lotofacil", totalNumbers: 15, maxNumber: 25),
        GameConfig(name: "Quina", totalNumbers: 5, maxNumber: 80),
        GameConfig(name: "Lotomania", totalNumbers: 50, maxNumber: 100)
    ]
    
    func randomLottoNumberGenerator(total: Int, maxNumber: Int) -> [String] {
        var numbers = total
        var result: Set<String> = []
        
        while numbers > 0 {
            let generated = Int.random(in: 1...maxNumber)
            
            let numberToAdd = (generated == 100) ? "00" : String(format: "%02d", generated)

            
            let res = result.insert(numberToAdd)
            if res.inserted {
                numbers -= 1
            }
        }
        
        //order the generated numbers
        var sortedResult = result.sorted()
        
        //move "00" to the last position when its generated
        if let index = sortedResult.firstIndex(of: "00") {
            sortedResult.append(sortedResult.remove(at: index))
        }
        return sortedResult
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
                                .frame(height: 80)
                                .onTapGesture {
                                    selectedGameConfig = config
                                    // Sempre que abrir o modal para Mega-Sena, mantém o valor selecionado pelo usuário
                                    generateNumbersForSelectedGame()
                                    showCustomAlert = true
                                }
                            Text(config.name)
                                .dynamicTypeSize(.medium ... .accessibility3)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.black)
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    // Botão "Apostar" só aparece se a região for BR e o jogo selecionado for Mega-Sena
                    if Locale.current.regionCode == "BR" && selectedGameConfig?.name == "Mega-Sena" {
                        Button(action: {
                            if let url = URL(string: "loterias://caixa") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    if let appStoreUrl = URL(string: "https://apps.apple.com/br/app/loterias-caixa/id1436530324?l=en-GB") {
                                        UIApplication.shared.open(appStoreUrl)
                                    }
                                }
                            }
                        }) {
                            Text("Apostar")
                                .dynamicTypeSize(.medium ... .accessibility3)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 120)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
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
                        
                        // Custom selector for Mega-Sena number amount replacing the old Stepper
                        if selectedGameType == "Mega-Sena" {
                            // Seletor customizado para Mega-Sena
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quantidade de números:")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.22, green: 0.28, blue: 0.38))
                                HStack(spacing: 16) {
                                    Button(action: {
                                        if megaSenaNumbersAmount > 6 {
                                            megaSenaNumbersAmount -= 1
                                        }
                                    })
                                    {
                                        Text("-")
                                            .dynamicTypeSize(.medium ... .accessibility3)
                                            .minimumScaleFactor(0.7)
                                            .lineLimit(1)
                                            .font(.system(size: 28, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                                            )
                                            // Diminuir opacidade e desabilitar botão quando estiver no limite inferior (6)
                                            .opacity(megaSenaNumbersAmount == 6 ? 0.3 : 1.0)
                                            .disabled(megaSenaNumbersAmount == 6)
                                    }
                                    Text("\(megaSenaNumbersAmount)")
                                        .dynamicTypeSize(.medium ... .accessibility3)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .font(.system(size: 28, weight: .semibold))
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
                                        if megaSenaNumbersAmount < 20 {
                                            megaSenaNumbersAmount += 1
                                        }
                                    }) {
                                        Text("+")
                                            .dynamicTypeSize(.medium ... .accessibility3)
                                            .minimumScaleFactor(0.7)
                                            .lineLimit(1)
                                            .font(.system(size: 28, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                                            )
                                            // Diminuir opacidade e desabilitar botão quando estiver no limite superior (20)
                                            .opacity(megaSenaNumbersAmount == 20 ? 0.3 : 1.0)
                                            .disabled(megaSenaNumbersAmount == 20)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .padding(.leading)
                            .padding(.top, 6)
                        }
                        
                        // Custom selector for Lotofacil number amount
                        if selectedGameType == "Lotofacil" {
                            // Seletor customizado para Lotofacil com intervalo 15 a 20
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quantidade de números:")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.22, green: 0.28, blue: 0.38))
                                HStack(spacing: 16) {
                                    Button(action: {
                                        if lotofacilNumbersAmount > 15 {
                                            lotofacilNumbersAmount -= 1
                                        }
                                    }) {
                                        Text("-")
                                            .dynamicTypeSize(.medium ... .accessibility3)
                                            .minimumScaleFactor(0.7)
                                            .lineLimit(1)
                                            .font(.system(size: 28, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                                            )
                                            // Diminuir opacidade e desabilitar botão quando estiver no limite inferior (15)
                                            .opacity(lotofacilNumbersAmount == 15 ? 0.3 : 1.0)
                                            .disabled(lotofacilNumbersAmount == 15)
                                    }
                                    Text("\(lotofacilNumbersAmount)")
                                        .dynamicTypeSize(.medium ... .accessibility3)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .font(.system(size: 28, weight: .semibold))
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
                                        if lotofacilNumbersAmount < 20 {
                                            lotofacilNumbersAmount += 1
                                        }
                                    }) {
                                        Text("+")
                                            .dynamicTypeSize(.medium ... .accessibility3)
                                            .minimumScaleFactor(0.7)
                                            .lineLimit(1)
                                            .font(.system(size: 28, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                                            )
                                            // Diminuir opacidade e desabilitar botão quando estiver no limite superior (20)
                                            .opacity(lotofacilNumbersAmount == 20 ? 0.3 : 1.0)
                                            .disabled(lotofacilNumbersAmount == 20)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .padding(.leading)
                            .padding(.top, 6)
                        }
                        
                        // Custom selector for Quina number amount
                        if selectedGameType == "Quina" {
                            // Seletor customizado para Quina com intervalo 5 a 15
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quantidade de números:")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.22, green: 0.28, blue: 0.38))
                                HStack(spacing: 16) {
                                    Button(action: {
                                        if quinaNumbersAmount > 5 {
                                            quinaNumbersAmount -= 1
                                        }
                                    }) {
                                        Text("-")
                                            .dynamicTypeSize(.medium ... .accessibility3)
                                            .minimumScaleFactor(0.7)
                                            .lineLimit(1)
                                            .font(.system(size: 28, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                                            )
                                            // Diminuir opacidade e desabilitar botão quando estiver no limite inferior (5)
                                            .opacity(quinaNumbersAmount == 5 ? 0.3 : 1.0)
                                            .disabled(quinaNumbersAmount == 5)
                                    }
                                    Text("\(quinaNumbersAmount)")
                                        .dynamicTypeSize(.medium ... .accessibility3)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .font(.system(size: 28, weight: .semibold))
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
                                        if quinaNumbersAmount < 15 {
                                            quinaNumbersAmount += 1
                                        }
                                    }) {
                                        Text("+")
                                            .dynamicTypeSize(.medium ... .accessibility3)
                                            .minimumScaleFactor(0.7)
                                            .lineLimit(1)
                                            .font(.system(size: 28, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.12, green: 0.43, blue: 0.74))
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color(red: 0.12, green: 0.43, blue: 0.74), lineWidth: 1)
                                            )
                                            // Diminuir opacidade e desabilitar botão quando estiver no limite superior (15)
                                            .opacity(quinaNumbersAmount == 15 ? 0.3 : 1.0)
                                            .disabled(quinaNumbersAmount == 15)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .padding(.leading)
                            .padding(.top, 6)
                        }
                        
                        Text(alertMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.black)
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
                }
            }
        }
    }
}
#Preview {
    GeneratingNumbersView(viewModel: GeneratingNumbersViewModel())
}

