import Foundation
import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var allResults: [LotteryResult] = []
    @Published var filteredResults: [LotteryResult] = []
    @Published var isLoading = false
    @Published var selectedGame: GameType? = nil
    @Published var contestQuery: String = ""

    private let service = HistoryService()
    
    private func mapTipoJogo(_ raw: String) -> GameType? {
        switch raw.uppercased() {
        case "MEGA_SENA": return .megasena
        case "QUINA": return .quina
        case "LOTOMANIA": return .lotomania
        case "LOTOFACIL": return .lotofacil
        default: return nil
        }
    }

    func loadInitial() async {
        isLoading = true
        defer { isLoading = false }
        do {
            var combined: [LotteryResult] = []
            for game in [GameType.megasena, .quina, .lotomania, .lotofacil] {
                let last = try await service.fetchLast(game: game)
                combined.append(last)
                var currentNumber = last.numero
                for _ in 1..<5 { // buscar 4 anteriores para totalizar 5
                    currentNumber -= 1
                    guard currentNumber > 0 else { break }
                    do {
                        let result = try await service.fetchResult(game: game, contest: String(currentNumber))
                        combined.append(result)
                    } catch {
                        // Se falhar algum específico, continua
                        continue
                    }
                }
            }
            combined.sort { lhs, rhs in
                if lhs.tipoJogo == rhs.tipoJogo {
                    return lhs.numero > rhs.numero
                }
                return lhs.tipoJogo < rhs.tipoJogo
            }
            self.allResults = combined
            self.filteredResults = combined
        } catch {
            print("Erro ao carregar histórico: \(error)")
        }
    }

    func applyFilters() {
        var results = allResults

        if let game = selectedGame {
            results = results.filter { mapTipoJogo($0.tipoJogo) == game }
        }

        let query = contestQuery.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            results = results.filter { "\($0.numero)".contains(query) }
        }

        filteredResults = results
    }

    func clearFilters() {
        selectedGame = nil
        contestQuery = ""
        filteredResults = allResults
    }
}
