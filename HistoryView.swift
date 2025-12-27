import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.30)

            ScrollView {
                VStack(spacing: 16) {
                    filterBar

                    if viewModel.isLoading {
                        ProgressView("Carregando histórico...")
                            .padding(.top, 24)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredResults) { item in
                                HistoryCard(item: item)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Histórico")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInitial()
        }
        .onChange(of: viewModel.selectedGame) { _ in
            viewModel.applyFilters()
        }
        .onChange(of: viewModel.contestQuery) { _ in
            viewModel.applyFilters()
        }
    }

    private var filterBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Menu {
                    Button("Todos") { viewModel.selectedGame = nil }
                    ForEach(GameType.allCases) { game in
                        Button(game.displayName) { viewModel.selectedGame = game }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedGame?.displayName ?? "Todos os jogos")
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.59))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.08)))
                    )
                }

                TextField("Concurso #", text: $viewModel.contestQuery)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 150)
            }

            HStack {
                Spacer()
                Button("Limpar filtros") {
                    viewModel.clearFilters()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(maxWidth: 150)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

private struct HistoryCard: View {
    let item: LotteryResult

    var gameType: GameType? {
        switch item.tipoJogo.uppercased() {
        case "MEGA_SENA": return .megasena
        case "QUINA": return .quina
        case "LOTOMANIA": return .lotomania
        case "LOTOFACIL": return .lotofacil
        default: return nil
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let game = gameType {
                Image(game.logoAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 28, weight: .regular))
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(gameType?.displayName ?? item.tipoJogo)
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)

                if let dezenas = item.listaDezenas, !dezenas.isEmpty {
                    InlineBallsRowView(numbersString: dezenas.joined(separator: " 🍀 "))
                } else {
                    Text("Sem dezenas disponíveis")
                        .font(.footnote)
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                HStack(spacing: 12) {
                    Text("Concurso: \(item.numero)")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                    Text(item.acumulado ? "Acumulou: Sim" : "Acumulou: Não")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(item.acumulado ? .green : .orange)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
