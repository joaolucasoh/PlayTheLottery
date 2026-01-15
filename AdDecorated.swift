import SwiftUI

struct AdDecorated<Content: View>: View {
    @EnvironmentObject private var adSettings: AdSettings
    let content: Content

    // Local AdBannerHost to avoid cross-file dependency
    @ViewBuilder
    private func AdBannerHost() -> some View {
        if !adSettings.adsRemoved {
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50)
                .background(Color(white: 1.0, opacity: 0.85))
        } else {
            Color.clear.frame(height: 0)
        }
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .safeAreaInset(edge: .top) {
                AdBannerHost()
            }
            .safeAreaInset(edge: .bottom) {
                AdBannerHost()
            }
    }
}
