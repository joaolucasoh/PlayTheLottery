//
//  GeneratingNumbersView.swift
//  PlayTheLottery
//
//  Created by joaolucas on 26/09/24.
//

import SwiftUI

struct GeneratingNumbersView: View {
    
    @ObservedObject var viewModel: GeneratingNumbersViewModel
    
    struct MyVariables {
        static var lottery = ""
    }
    
    // Exemplo de variável de estado para o botão de compartilhamento
    @State private var isShareButtonEnabled: Bool = true
    
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
                    Text("Mega-Sena")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
                VStack {
                    Image("loto-facil-button")
                    Text("Lotofácil")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
            }
            
            HStack {
                VStack {
                    Image("quina-button")
                    Text("Quina")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
                VStack {
                    Image("lotomania-button")
                    Text("Lotomania")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                }
            }
            
            HStack( spacing: 20) {
                VStack {
                    Button(action: {
                        // Adicione a ação para o botão "Apostar" aqui
                    }) {
                        Text("Apostar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // Botão Compartilhar
                    VStack {
                        Button(action: {
                            // Ação para o botão Compartilhar
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
                    .frame(maxWidth: .infinity)//  Garante que o VStack ocupe toda a largura disponível
                    .background(Color.white)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    GeneratingNumbersView(viewModel: GeneratingNumbersViewModel()) // Substitua pelo viewModel apropriado
}
