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
    @State private var slideIn = false
    var body: some View {
        ZStack(alignment: .center) {
            Image("banner")
                .resizable()
                .scaledToFit()
                .offset(y: slideIn ? 0 : 12)
                .opacity(slideIn ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: slideIn)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 1)
                .background(Color.white)
                .ignoresSafeArea()
            
            Text("Copyright @ Raven 🐦‍⬛")
                .foregroundColor(Color.gray)
                .font(Font.system(size: 16).bold())
                .padding(.top, 600)
        }
        .onAppear { slideIn = true }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SplashViewModel()
        SplashView(viewModel: viewModel)
    }
}
