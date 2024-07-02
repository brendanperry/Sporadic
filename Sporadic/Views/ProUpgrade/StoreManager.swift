//
//  StoreManager.swift
//  Sporadic
//
//  Created by brendan on 4/6/24.
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    var hasProUpgrade: Bool {
        return purchasedProductIDs.contains("sporadic_pro")
    }
    @Published var proUpgradeProduct: Product?
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        Task {
            do {
                if let product = try await getProducts(ids: ["sporadic_pro"])?.first {
                    proUpgradeProduct = product
                }
            } catch {
                print(error)
            }
        }
        
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func getProducts(ids: [String]) async throws -> [Product]? {
        return try await Product.products(for: ids)
    }
    
    func purchasePro() async -> Bool {
        guard let proUpgradeProduct else { return false }
        let wasSuccessful = try? await purchase(proUpgradeProduct)
        return wasSuccessful ?? false
    }
    
    private func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(.verified(_)):
            return true
        default:
            return false
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await _ in Transaction.updates {
                await self?.updatePurchasedProducts()
            }
        }
    }
    
    // Probably not need but better to be safe
    func restorePurchases() async {
        try? await AppStore.sync()
    }
}
