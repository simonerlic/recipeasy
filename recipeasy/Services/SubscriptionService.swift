//
//  SubscriptionService.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//

import StoreKit
import SwiftUI

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    
    private var updateListenerTask: Task<Void, Error>?
    
    let subscriptionGroupID = "dev.serlic.recipeasypro"
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }
    }
    
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        let transaction = try? result.payloadValue
        guard let transaction = transaction else { return }
        
        // Handle transaction and update purchasedSubscriptions
        await updateCustomerProductStatus()
        
        // Always finish a transaction
        await transaction.finish()
    }
    
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: [subscriptionGroupID])
            subscriptions = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to request products:", error)
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCustomerProductStatus()
            return transaction
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? result.payloadValue else { continue }
            
            guard let subscription = subscriptions.first(where: { $0.id == transaction.productID }) else { continue }
            
            purchasedSubscriptions.append(subscription)
        }
        
        self.purchasedSubscriptions = purchasedSubscriptions
    }
    
    var hasActiveSubscription: Bool {
        !purchasedSubscriptions.isEmpty
    }
}

extension SubscriptionService {
    func restorePurchases() async throws {
        try? await AppStore.sync()
        await updateCustomerProductStatus()
    }
}

enum StoreError: Error {
    case failedVerification
    case unknownError
}
