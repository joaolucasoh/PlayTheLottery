import SwiftUI

struct MainMenuView: View {
    var body: some View {
        CompatibleNavigationContainer {
            content
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
                    .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    NavigationLink(destination: GeneratingNumbersView(viewModel: GeneratingNumbersViewModel())) {
                        MenuCard(
                            title: "Gerador de Números",
                            subtitle: "Monte jogos rapidamente",
                            systemImage: "sparkles",
                            date: nil
                        )
                    }

                    NavigationLink(destination: FavoriteNumbersView()) {
                        MenuCard(
                            title: "Meus números favoritos",
                            subtitle: "Veja seus palpites favoritos",
                            systemImage: "star",
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
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 560)
                .padding(.horizontal, 70)
                .padding(.top, 12)

                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
        .frame(maxWidth: .infinity, minHeight: 76, maxHeight: 76)
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

