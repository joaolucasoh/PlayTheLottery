// Serviço para gerenciar números favoritos.
import Foundation
import SwiftUI

struct FavoriteNumberEntry: Identifiable, Codable, Equatable {
    let id: UUID = UUID()
    let gameType: String // ex: "Mega-Sena"
    let numbers: [String] // ex: ["01", "23", "44", ...]
    let savedAt: Date

    var displayString: String {
        numbers.joined(separator: " 🍀 ")
    }
}

class FavoriteNumbersService: ObservableObject {
    static let shared = FavoriteNumbersService()

    @Published private(set) var favorites: [FavoriteNumberEntry] = []

    private let storageKey = "favorite_numbers_entries"
    private var isLoaded = false

    private init() {
        load()
    }

    func isFavorited(gameType: String, numbers: [String]) -> Bool {
        favorites.contains(where: { $0.gameType == gameType && $0.numbers == numbers })
    }

    func addFavorite(gameType: String, numbers: [String]) {
        guard !isFavorited(gameType: gameType, numbers: numbers) else { return }
        let entry = FavoriteNumberEntry(gameType: gameType, numbers: numbers, savedAt: Date())
        favorites.append(entry)
        save()
    }

    func removeFavorite(gameType: String, numbers: [String]) {
        favorites.removeAll(where: { $0.gameType == gameType && $0.numbers == numbers })
        save()
    }

    private func load() {
        guard !isLoaded else { return }
        isLoaded = true
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FavoriteNumberEntry].self, from: data) {
            favorites = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
