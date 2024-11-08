//
//  HomeViewRouter.swift
//  PlayTheLottery
//
//  Created by joaolucas on 01/10/24.
//


import SwiftUI

enum HomeViewRouter {
    static func homeView() -> some View {
        let viewModel = HomeViewModel()
        
        return HomeView(viewModel: viewModel)
    }
}
