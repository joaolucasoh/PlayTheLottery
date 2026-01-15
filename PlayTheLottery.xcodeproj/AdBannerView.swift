import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    var adSize: GADAdSize = GADAdSizeBanner

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.delegate = context.coordinator
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {}
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            #if DEBUG
            print("Ad failed to load: \(error.localizedDescription)")
            #endif
        }
    }
}
#else

// Fallback stub so the app builds without GoogleMobileAds yet
struct AdBannerView: View {
    let adUnitID: String
    var body: some View {
        Color.clear.frame(height: 0)
    }
}

#endif

