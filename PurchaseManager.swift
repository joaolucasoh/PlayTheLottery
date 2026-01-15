import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var removeAdsPurchased: Bool = false
    private let removeAdsProductID = "com.seuapp.remove_ads" // TODO: replace with your real product ID

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactions()
    }

    deinit { updatesTask?.cancel() }

    func loadPurchasedState() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == removeAdsProductID {
                removeAdsPurchased = true
                return
            }
        }
        removeAdsPurchased = false
    }

    func purchaseRemoveAds() async throws {
        let products = try await Product.products(for: [removeAdsProductID])
        guard let product = products.first else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                removeAdsPurchased = true
                await transaction.finish()
            }
        case .userCancelled, .pending:
            break
        @unknown default: break
        }
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = result,
                   transaction.productID == self.removeAdsProductID {
                    await MainActor.run {
                        self.removeAdsPurchased = true
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
