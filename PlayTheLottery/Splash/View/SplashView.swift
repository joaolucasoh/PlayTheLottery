//
//  SplashView.swift
//  PlayTheLottery
//
//  Created by joaolucas on 26/09/24.
//

import SwiftUI

struct SplashView: View {
    
    @ObservedObject var viewModel: SplashViewModel
    
    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                LoadingView()
            case .homeScreen:
                Text("HomeScreen")
            case .generateNumbers:
                viewModel.generatingNumbersView()
            case .error(let msg):
                Text("error \(msg)")
            }
        }.onAppear(perform: {
            viewModel.onAppear()
        })
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack(alignment: .center) {
            Image("banner")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 1)
                .background(Color.white)
                .ignoresSafeArea()
            
            Text("It's time to play")
                .foregroundColor(.green)
                .font(Font.system(.title3).bold())
                .padding(.top, 20)
            Text("Copyright @ Raven 🐦‍⬛")
                .foregroundColor(Color.gray)
                .font(Font.system(size: 16).bold())
                .padding(.top, 600)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SplashViewModel()
        SplashView(viewModel: viewModel)
    }
}
