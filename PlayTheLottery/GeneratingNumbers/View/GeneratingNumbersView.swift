import SwiftUI

struct GeneratingNumbersView: View {
    
    @State private var alertMessage = ""
    @State private var showCustomAlert = false
    @State private var isShareButtonEnabled = false
    @State private var selectedGameType = ""
    @State private var selectedGameConfig: GameConfig?
    
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
        var numbers = total - 1
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
        let generatedNumbers = randomLottoNumberGenerator(total: config.totalNumbers, maxNumber: config.maxNumber)
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
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.5)
                    .bold()
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
                                    generateNumbersForSelectedGame()
                                    showCustomAlert = true
                                }
                            Text(config.name)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.black)
                                .bold()
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        if let url = URL(string: "loterias://caixa") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                if let appStoreUrl = URL(string: "https://apps.apple.com/br/app/loterias-caixa/id1436530324?l=en-GB"){
                                    UIApplication.shared.open(appStoreUrl)
                                }
                            }
                        }
                    }) {
                        Text("Apostar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .sheet(isPresented: $showCustomAlert) {
                    VStack(spacing: 20) {
                        Text("Números gerados para ")
                            .font(.title)
                            .foregroundColor(.black)
                        Text("\(selectedGameType):")
                            .font(.title)
                            .bold()
                            .foregroundColor(.black)
                        Text(alertMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.black)
                        
                    }
                    VStack {
                        HStack {
                            Button("Gerar") {
                                generateNumbersForSelectedGame() // Gera novos números sem fechar o alert
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Button("Compartilhar") {
                                shareViaWhatsApp(gameType: selectedGameType, message: alertMessage)
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!isShareButtonEnabled) // Desabilita o botão se não houver números gerados
                            
                            Button("Voltar") {
                                showCustomAlert = false // Fecha o alert
                            }
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
                        if alertMessage.isEmpty { // Garante que números são gerados antes de mostrar o alerta
                            generateNumbersForSelectedGame()
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    GeneratingNumbersView(viewModel: GeneratingNumbersViewModel()) // Certifique-se de ter um viewModel válido ou substitua com um mock
}
