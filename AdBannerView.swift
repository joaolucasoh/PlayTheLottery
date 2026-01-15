import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    var adSize: AdSize = AdSizeBanner

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

#else

struct AdBannerView: View {
    let adUnitID: String
    var body: some View { Color.clear }
}

#endif
