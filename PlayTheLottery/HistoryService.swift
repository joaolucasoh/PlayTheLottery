import Foundation

struct LotteryResult: Decodable, Identifiable {
    var id: String { "\(tipoJogo)-\(numero)" }

    let tipoJogo: String
    let numero: Int
    let listaDezenas: [String]?
    let acumulado: Bool

    enum CodingKeys: String, CodingKey {
        case tipoJogo
        case numero
        case listaDezenas
        case acumulado
    }
}

enum GameType: String, CaseIterable, Identifiable {
    case megasena = "megasena"
    case quina = "quina"
    case lotomania = "lotomania"
    case lotofacil = "lotofacil"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .megasena: return "Mega-Sena"
        case .quina: return "Quina"
        case .lotomania: return "Lotomania"
        case .lotofacil: return "Lotofácil"
        }
    }

    var logoAssetName: String {
        switch self {
        case .megasena: return "mega-sena-button" // adjust to your actual asset name
        case .quina: return "quina-button"
        case .lotomania: return "lotomania-button"
        case .lotofacil: return "lotofacil-button"
        }
    }
}

struct HistoryService {
    private let baseURL = URL(string: "https://api.guidi.dev.br/loteria")!

    func fetchResult(game: GameType, contest: String) async throws -> LotteryResult {
        let url = baseURL.appendingPathComponent(game.rawValue).appendingPathComponent(contest)
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(LotteryResult.self, from: data)
    }

    func fetchLast(game: GameType) async throws -> LotteryResult {
        try await fetchResult(game: game, contest: "ultimo")
    }
}
