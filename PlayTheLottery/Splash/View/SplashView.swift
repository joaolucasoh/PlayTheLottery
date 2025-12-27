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
                NavigationStack {
                    MainMenuView()
                }
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
            Image("splash-screen")
                .resizable()
                .scaledToFill()
                .opacity(0.7)
                .ignoresSafeArea()

            // Optional: keep a subtle animated logo/banner on top
            Image("banner")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 400)
                .offset(y: slideIn ? 0 : 12)
                .opacity(slideIn ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: slideIn)
                .padding(.horizontal, 1)

            VStack {
                Spacer()
                Text("Copyright @ Raven 🐦‍⬛")
                    .foregroundColor(Color.black)
                    .font(Font.system(size: 16).bold())
                    .padding(.bottom, 24)
            }
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

