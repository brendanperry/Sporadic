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
    
    @Published var isPro = false
    @Published var proUpgradeProduct: Product?
    var purchasedProductIDs = Set<String>()
    
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
            
            await updatePurchasedProducts()
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
        let wasSuccessful = (try? await purchase(proUpgradeProduct)) ?? false
        if wasSuccessful {
            await updatePurchasedProducts()
        }
        return wasSuccessful
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
        
        Task { @MainActor in
            let hasPaid = await hasPaidForApp()
            isPro = hasPaid || purchasedProductIDs.contains("sporadic_pro")
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await _ in Transaction.updates {
                await self?.updatePurchasedProducts()
            }
        }
    }
    
    func hasPaidForApp() async -> Bool {
        guard let user = try? await CloudKitHelper.shared.getCurrentUser(forceSync: false) else {
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .gmt
        dateFormatter.dateFormat = "yyyy-MM-dd mm:HH:ss"
        guard let date = dateFormatter.date(from: "2024-08-20 00:00:00") else {
            return false
        }
        
        return user.createdAt < date
    }
    
    func restore() async {
        try? await AppStore.sync()
        
        await updatePurchasedProducts()
    }
}
