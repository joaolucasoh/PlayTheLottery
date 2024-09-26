//
//  SplashViewModel.swift
//  PlayTheLottery
//
//  Created by joaolucas on 26/09/24.
//

import SwiftUI

class SplashViewModel: ObservableObject {
    
    @Published var uiState: SplashUIState = .loading
    
    func onAppear() {
        // faz algo assincrono e muda o estado do UIState
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // aqui é chamado depois de 3 segundos
            self.uiState = .generateNumbers
        }
    }
    
    func generatingNumbersView() -> some View {
        return SplashViewRouter.makeGeneratingNumbersView()
    }
    
}
