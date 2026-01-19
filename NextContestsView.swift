import SwiftUI

struct NextContestInfo: Identifiable {
    let id: String
    let game: GameType
    let valorEstimadoProximoConcurso: Double?
    let numeroConcursoProximo: Int?
    let dataProximoConcurso: String?
}

private struct NextContestDTO: Decodable {
    let valorEstimadoProximoConcurso: Double?
    let numeroConcursoProximo: Int?
    let dataProximoConcurso: String?
}

final class NextContestsViewModel: ObservableObject {
    @Published var items: [NextContestInfo] = []
    @Published var isLoading = false
    
    @MainActor
    func load() async {
        isLoading = true
        await withTaskGroup(of: NextContestInfo?.self) { group in
            for game in GameType.allCases {
                group.addTask {
                    await self.fetchNext(for: game)
                }
            }
            
            var loadedItems: [NextContestInfo] = []
            for await item in group {
                if let item = item {
                    loadedItems.append(item)
                }
            }
            loadedItems.sort { a, b in
                GameType.allCases.firstIndex(of: a.game)! < GameType.allCases.firstIndex(of: b.game)!
            }
            items = loadedItems
            isLoading = false
        }
    }
    
    private func fetchNext(for game: GameType) async -> NextContestInfo? {
        do {
            let url = URL(string: "https://api.guidi.dev.br/loteria/\(game.rawValue)/ultimo")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let dto = try JSONDecoder().decode(NextContestDTO.self, from: data)
            return NextContestInfo(
                id: game.rawValue,
                game: game,
                valorEstimadoProximoConcurso: dto.valorEstimadoProximoConcurso,
                numeroConcursoProximo: dto.numeroConcursoProximo,
                dataProximoConcurso: dto.dataProximoConcurso
            )
        } catch {
            return NextContestInfo(
                id: game.rawValue,
                game: game,
                valorEstimadoProximoConcurso: nil,
                numeroConcursoProximo: nil,
                dataProximoConcurso: nil
            )
        }
    }
}

extension NextContestsViewModel {
    @MainActor
    func scheduleTodayNotificationsIfNeeded(formatter: DateFormatter, currencyFormatter: NumberFormatter) async {
        let granted = (try? await NotificationsManager.requestAuthorization()) ?? false
        guard granted else { return }

        NotificationsManager.clearScheduledNotifications()

        let today = Calendar.current.startOfDay(for: Date())

        let todayItems = items.compactMap { info -> (Date, Double?)? in
            guard let dateStr = info.dataProximoConcurso,
                  let date = formatter.date(from: dateStr) else { return nil }
            let day = Calendar.current.startOfDay(for: date)
            guard day == today else { return nil }
            return (date, info.valorEstimadoProximoConcurso)
        }

        guard !todayItems.isEmpty else { return }

        let estimates = todayItems.compactMap { $0.1 }
        let minVal = estimates.min()
        let maxVal = estimates.max()

        let minText = minVal.flatMap { currencyFormatter.string(from: NSNumber(value: $0)) }
        let maxText = maxVal.flatMap { currencyFormatter.string(from: NSNumber(value: $0)) }

        NotificationsManager.scheduleDailyContestReminders(for: Date(), minPrizeText: minText, maxPrizeText: maxText)
    }
}

struct NextContestsView: View {
    @StateObject private var vm = NextContestsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        return f
    }()
    
    private let localDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Indisponível" }
        // A API retorna no formato dd/MM/yyyy (ex: "31/12/2025")
        if let date = localDateFormatter.date(from: dateString) {
            return localDateFormatter.string(from: date)
        } else {
            return "Indisponível"
        }
    }
    
    var body: some View {
        LoadingOverlay(isLoading: $vm.isLoading, message: "Buscando próximos concursos. Aguarde...", numbers: [3, 9, 12, 27, 38, 52], size: 44, speed: 0.4) {
            ZStack {
                Image("splash-screen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.30)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.items) { item in
                            card(for: item)
                                .frame(maxWidth: 560)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .task {
            await vm.load()
            await vm.scheduleTodayNotificationsIfNeeded(formatter: localDateFormatter, currencyFormatter: currencyFormatter)
        }
        .navigationTitle("Próximos concursos")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func card(for item: NextContestInfo) -> some View {
//        Divider()
        VStack(alignment: .center, spacing: 10) {
            VStack(spacing: 6) {
                Image(item.game.logoAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .accessibilityHidden(true)
                Text(item.game.displayName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            VStack(alignment: .center, spacing: 4) {
                Text("Estimativa: \(textForEstimativa(item.valorEstimadoProximoConcurso))")
                Text("Data: \(formatDate(item.dataProximoConcurso))")
                Text("Concurso: \(textForConcurso(item.numeroConcursoProximo))")
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color("menu_card_background"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
//        Divider()
    }
    
    private func textForEstimativa(_ valor: Double?) -> String {
        if let valor = valor, let formatted = currencyFormatter.string(from: NSNumber(value: valor)) {
            return formatted
        } else {
            return "Indisponível"
        }
    }
    
    private func textForConcurso(_ numero: Int?) -> String {
        if let num = numero {
            return String(num)
        } else {
            return "Indisponível"
        }
    }
}

#Preview {
    NavigationStack {
        NextContestsView()
            .navigationTitle("Próximos concursos")
    }
}

