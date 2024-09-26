//
//  SplashViewRouter.swift
//  PlayTheLottery
//
//  Created by joaolucas on 26/09/24.
//

import SwiftUI

enum SplashViewRouter {
    static func makeGeneratingNumbersView() -> some View {
        let viewModel = GeneratingNumbersViewModel()
        
        return GeneratingNumbersView(viewModel: viewModel)
    }
}
