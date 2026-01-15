import Foundation
import UIKit

#if canImport(GoogleMobileAds)
import GoogleMobileAds

final class RewardedAdManager: NSObject, ObservableObject {
    @Published var isReady: Bool = false
    private var rewardedAd: RewardedAd?
    // Test Rewarded Unit ID (Google). Replace with your real unit ID in production.
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"

    func load() {
        RewardedAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            if let error = error {
                #if DEBUG
                print("[Rewarded] Load error: \(error)")
                #endif
                self?.rewardedAd = nil
                self?.isReady = false
                return
            }
            self?.rewardedAd = ad
            self?.isReady = true
        }
    }

    func present(from viewController: UIViewController, onReward: @escaping (Int, String) -> Void, onDismiss: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            // Not ready, try loading again
            load()
            return
        }
        isReady = false
        ad.fullScreenContentDelegate = self
        ad.present(from: viewController) {
            let reward = ad.adReward
            onReward(reward.amount.intValue, reward.type)
        }
    }
}

extension RewardedAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isReady = false
        // Preload for next time
        load()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        #if DEBUG
        print("[Rewarded] Present error: \(error)")
        #endif
        isReady = false
        load()
    }
}

#else

// Fallback stub to keep the project compiling without GoogleMobileAds
final class RewardedAdManager: NSObject, ObservableObject {
    @Published var isReady: Bool = false
    func load() {}
    func present(from viewController: UIViewController, onReward: @escaping (Int, String) -> Void, onDismiss: @escaping () -> Void) {
        // No-op in fallback
    }
}

#endif
