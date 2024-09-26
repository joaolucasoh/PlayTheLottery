//
//  GeneratingNumbersView.swift
//  PlayTheLottery
//
//  Created by joaolucas on 26/09/24.
//

import SwiftUI

struct GeneratingNumbersView: View {
    
    @State var generateNumbers = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var selectedGameType = ""
    @State private var isShareButtonEnabled = false
    
    @ObservedObject var viewModel: GeneratingNumbersViewModel
    
    struct MyVariables {
        static var lottery = ""
    }
    
    func randomLottoNumberGenerator(total: Int, maxNumber: Int) -> Set<Int> {
        var numbers = total
        var result: Set<Int> = []
        
        while numbers > 0 {
            let generated = Int.random(in: 1...maxNumber)
            let res = result.insert(generated)
            
            if res.inserted {
                numbers -= 1
            }
        }
        return result
    }
    
    func setToString(set: Set<Int>) -> String {
        let stringRepresentation = set.sorted().map { String($0) }.joined(separator: " 🍀 ")
        return stringRepresentation
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
        VStack(spacing: 60) {
            Text("Escolha para qual jogo deseja os números🤞🏽🍀")
                .font(.title)
                .bold()
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            
            HStack {
                VStack {
                    Image("mega-sena-button")
                        .onTapGesture {
                            generateNumbers.toggle()
                            let generatedNumber = randomLottoNumberGenerator(total: 6, maxNumber: 60)
                            alertMessage = setToString(set: generatedNumber)
                            selectedGameType = "Mega-Sena"
                            isShareButtonEnabled = true
                            showAlert = true
                        }
                    
                    Text("Mega-Sena")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
                VStack {
                    Image("loto-facil-button")
                        .onTapGesture {
                            generateNumbers.toggle()
                            let generatedNumber = randomLottoNumberGenerator(total: 15, maxNumber: 25)
                            alertMessage = setToString(set: generatedNumber)
                            selectedGameType = "Lotofácil"
                            isShareButtonEnabled = true
                            showAlert = true
                        }
                    Text("Lotofácil")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
            }
            
            HStack {
                VStack {
                    Image("quina-button")
                        .onTapGesture {
                            generateNumbers.toggle()
                            let generatedNumber = randomLottoNumberGenerator(total: 5, maxNumber: 80)
                            alertMessage = setToString(set: generatedNumber)
                            selectedGameType = "Quina"
                            isShareButtonEnabled = true
                            showAlert = true
                        }
                    Text("Quina")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
                VStack {
                    Image("lotomania-button")
                        .onTapGesture {
                            generateNumbers.toggle()
                            let generatedNumber = randomLottoNumberGenerator(total: 50, maxNumber: 100)
                            alertMessage = setToString(set: generatedNumber)
                            selectedGameType = "Lotomania"
                            isShareButtonEnabled = true
                            showAlert = true
                        }
                    Text("Lotomania")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
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
                
                Button(action: {
                     shareViaWhatsApp(gameType: selectedGameType, message: alertMessage)
                }) {
                    Text("Compartilhar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .disabled(!isShareButtonEnabled)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Os números são:"), message: Text(alertMessage), dismissButton: .default(Text("Boa Sorte!🤞🏽")))
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .padding()
    }
}

#Preview {
    GeneratingNumbersView(viewModel: GeneratingNumbersViewModel()) // Certifique-se de ter um viewModel válido ou substitua com um mock
}
