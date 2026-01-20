import Foundation
import SwiftUI

// Fallback SimpleCache if shared file isn't in target
fileprivate struct SimpleCache {
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: key + ":lastUpdated")
        }
    }

    static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> (data: T, lastUpdated: Date)? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(T.self, from: data) else { return nil }
        let last = UserDefaults.standard.object(forKey: key + ":lastUpdated") as? Date ?? Date.distantPast
        return (decoded, last)
    }

    static func shouldRefresh(lastUpdated: Date, calendar: Calendar = .current, now: Date = Date()) -> Bool {
        let startOfToday = calendar.startOfDay(for: now)
        if lastUpdated < startOfToday { return true }
        let comps = calendar.dateComponents([.year, .month, .day], from: now)
        var at22 = DateComponents()
        at22.year = comps.year
        at22.month = comps.month
        at22.day = comps.day
        at22.hour = 22
        at22.minute = 0
        at22.second = 0
        if let tenPM = calendar.date(from: at22) {
            if now >= tenPM && lastUpdated < tenPM { return true }
        }
        return false
    }
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var allResults: [LotteryResult] = []
    @Published var filteredResults: [LotteryResult] = []
    @Published var isLoading = false
    @Published var selectedGame: GameType? = nil
    @Published var contestQuery: String = ""
    
    private let service = HistoryService()
    private let cacheKey = "history_results_cache"
    private let calendar = Calendar.current
    private var isFetching = false
    
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
        if isFetching { return }
        isFetching = true
        defer { isFetching = false }
        isLoading = true
        defer { isLoading = false }
        // Load from cache first
        if let cached: (data: [LotteryResult], lastUpdated: Date) = SimpleCache.load([LotteryResult].self, forKey: cacheKey) {
            self.allResults = cached.data
            self.filteredResults = cached.data
            if !SimpleCache.shouldRefresh(lastUpdated: cached.lastUpdated, calendar: calendar) {
                return
            }
        }
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
            SimpleCache.save(combined, forKey: cacheKey)
        } catch {
            print("Erro ao carregar histórico: ", error)
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
