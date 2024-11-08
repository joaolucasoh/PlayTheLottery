//
//  HomeView.swift
//  PlayTheLottery
//
//  Created by joaolucas on 26/09/24.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Text("Selecione uma opção:")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.5)
                    .bold()
                    .padding(.bottom, 100)
                
                VStack(spacing: 40) {
                    HStack(spacing: 20) {
                        Image("history")
                            .padding()
                            .scaledToFit()
                            Text("Histórico de números")
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Image("generate-numbers")
                            .padding()
                            .scaledToFit()
                            Text("Gerador de números")
                    }
                }
            }
        }
    }
    
#Preview {
    HomeView(viewModel: HomeViewModel())
}
