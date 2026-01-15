import SwiftUI

struct FavoriteNumbersView: View {
    var body: some View {
        ZStack {
            // Fundo similar ao dos outros menus
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Meus números favoritos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Nenhum favorito salvo ainda.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Favoritos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
