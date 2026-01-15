import SwiftUI

struct MainMenuView: View {
    @StateObject private var rewardedManager = RewardedAdManager()
    @State private var premiumHintsUnlockedUntil: Date? = nil
    
    @EnvironmentObject private var adSettings: AdSettings
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        CompatibleNavigationContainer {
            AdDecorated {
                content
            }
        }
        .safeAreaInset(edge: .bottom) {
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50)
                .background(Color(white: 1.0, opacity: 0.85))
        }
        .onAppear {
            rewardedManager.load()
        }
    }

    private var content: some View {
        ZStack {
            // Reutiliza o mesmo background do app
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.30)

            VStack(spacing: 24) {
                Text("Menu")
                    .font(.largeTitle.bold())
                    .foregroundColor(.black)
                    .padding(.top, 24)
                    .padding(.horizontal, 28)

                VStack(spacing: 16) {
                    NavigationLink(destination: GeneratingNumbersView(viewModel: GeneratingNumbersViewModel())) {
                        MenuCard(
                            title: "Gerador de Números",
                            subtitle: "Monte jogos rapidamente",
                            systemImage: "sparkles",
                            date: nil
                        )
                    }

                    NavigationLink(destination: HistoryView()) {
                        MenuCard(
                            title: "Histórico de Concursos",
                            subtitle: "Veja resultados anteriores",
                            systemImage: "clock.arrow.circlepath",
                            date: nil
                        )
                    }

                    NavigationLink(destination: NextContestsView()) {
                        MenuCard(
                            title: "Próximos concursos",
                            subtitle: "Estimativas, datas e números",
                            systemImage: "calendar.badge.clock",
                            date: nil
                        )
                    }

                    Button {
                        showRewarded()
                    } label: {
                        MenuCard(
                            title: canShowPremiumHints ? "Dicas Premium Ativas" : "Ganhar Dicas Premium",
                            subtitle: canShowPremiumHints ? remainingPremiumTimeText : (rewardedManager.isReady ? "Assista um anúncio recompensado" : "Carregando anúncio..."),
                            systemImage: canShowPremiumHints ? "star.circle.fill" : (rewardedManager.isReady ? "play.circle.fill" : "hourglass"),
                            date: nil
                        )
                    }
                    .disabled(!rewardedManager.isReady && !canShowPremiumHints)
                    
                    Button {
                        Task {
                            do {
                                try await purchaseManager.purchaseRemoveAds()
                                adSettings.adsRemoved = purchaseManager.removeAdsPurchased
                            } catch {
                                // handle error if needed
                            }
                        }
                    } label: {
                        MenuCard(
                            title: adSettings.adsRemoved ? "Anúncios Removidos" : "Remover Anúncios",
                            subtitle: adSettings.adsRemoved ? "Compra concluída" : "Pagamento único",
                            systemImage: adSettings.adsRemoved ? "checkmark.seal.fill" : "cart.badge.plus",
                            date: nil
                        )
                    }
                    .disabled(adSettings.adsRemoved)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 770)
                .padding(.horizontal, 28)
                .padding(.top, 12)

                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var canShowPremiumHints: Bool {
        if let until = premiumHintsUnlockedUntil { return Date() < until }
        return false
    }

    private var remainingPremiumTimeText: String {
        guard let until = premiumHintsUnlockedUntil else { return "" }
        let remaining = max(0, Int(until.timeIntervalSinceNow))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "Expira em %02d:%02d", minutes, seconds)
    }

    private func showRewarded() {
        guard let vc = topViewController() else { return }
        rewardedManager.present(from: vc, onReward: { amount, type in
            // Desbloqueia dicas por 10 minutos
            premiumHintsUnlockedUntil = Date().addingTimeInterval(10 * 60)
        }, onDismiss: {
            // opcional: ações após fechar
        })
    }

    private func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow?.rootViewController
    }
}

private struct CompatibleNavigationContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack { content() }
            } else {
                NavigationView { content() }
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

private struct MenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let date: Date?

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                if let date {
                    Text("Data do sorteio: \(date.formatted(.sorteioPadrao))")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.4))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .environmentObject(AdSettings())
            .environmentObject(PurchaseManager())
    }
}
extension FormatStyle where Self == Date.FormatStyle {
    static var sorteioPadrao: Self {
        var style = Date.FormatStyle()
        style.locale = Locale(identifier: "pt_BR")
        return style
            .day(.defaultDigits)
            .month(.abbreviated)
            .year(.defaultDigits)
    }
}

