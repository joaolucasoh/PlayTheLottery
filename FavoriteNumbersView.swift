import SwiftUI

struct FavoriteNumbersView: View {
    @ObservedObject private var service = FavoriteNumbersService.shared
    @State private var pendingDelete: FavoriteNumberEntry? = nil
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func ballAssetName(for number: String) -> String {
        let trimmed = number.trimmingCharacters(in: .whitespacesAndNewlines)
        if let intVal = Int(trimmed) {
            return "ball_\(intVal)" // no leading zero
        }
        return "ball_\(trimmed)"
    }
    
    private func normalized(_ text: String) -> String {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return lower.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    private func gameLogoName(for gameType: String) -> String? {
        switch normalized(gameType) {
        case "mega-sena", "mega sena", "megasena":
            return "mega-sena-button"
        case "lotofacil", "loto facil", "lotofácil":
            return "lotofacil-button"
        case "quina":
            return "quina-button"
        case "lotomania":
            return "lotomania-button"
        default:
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            Image("splash-screen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.30)
            
            if service.favorites.isEmpty {
                VStack(spacing: 20) {
                    Text("Meus números favoritos")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Nenhum favorito salvo ainda.")
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    Section {
                        Text("Meus números favoritos")
                            .font(.system(size: 27, weight: .bold))
                            .multilineTextAlignment(.center)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top)
                            .padding(.horizontal, 35)

                        ForEach(service.favorites) { favorite in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    if let logo = gameLogoName(for: favorite.gameType) {
                                        Image(logo)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 22)
                                    }
                                    Text(favorite.gameType)
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .padding(.bottom, 6)

                                let columns = Array(repeating: GridItem(.flexible(minimum: 36), spacing: 8), count: 6)
                                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                                    ForEach(favorite.numbers, id: \.self) { number in
                                        Image(ballAssetName(for: number))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                
                                Divider()
                                    .opacity(0.2)
                                    .padding(.vertical, 4)

                                Text(dateFormatter.string(from: favorite.savedAt))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: 560, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 24)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    pendingDelete = favorite
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Excluir sequência de números?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            presenting: pendingDelete
        ) { entry in
            Button("Cancelar", role: .cancel) {
                pendingDelete = nil
            }
            Button("Excluir", role: .destructive) {
                service.removeFavorite(gameType: entry.gameType, numbers: entry.numbers)
                pendingDelete = nil
            }
        } message: { entry in
            Text("Tem certeza que deseja excluir esta sequência salva? Ela será removida dos seus favoritos e não poderá ser recuperada.\n\nJogo: \(entry.gameType) — \(entry.numbers.count) números")
        }
    }
}

