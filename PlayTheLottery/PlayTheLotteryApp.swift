//
//  PlayTheLotteryApp.swift
//  PlayTheLottery
//
//  Created by joaolucas on 27/02/24.
//

import SwiftUI

@main
struct PlayTheLotteryApp: App {
    @StateObject private var adSettings = AdSettings()
    @StateObject private var purchaseManager = PurchaseManager()
    var body: some Scene {
        WindowGroup {
            SplashView(viewModel: SplashViewModel())
                .environmentObject(adSettings)
                .environmentObject(purchaseManager)
        }
    }
}

