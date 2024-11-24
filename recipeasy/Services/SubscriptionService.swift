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
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .unknown
    
    private var transactionListener: Task<Void, Error>?
    private var statusUpdateTimer: Timer?
    let subscriptionGroupID = "dev.serlic.recipeasypro"
    
    enum SubscriptionStatus {
        case unknown
        case subscribed
        case notSubscribed
    }
    
    init() {
        // Start transaction listener
        transactionListener = listenForTransactions()
        
        // Initial setup
        Task {
            await requestProducts()
            await updateSubscriptionStatus()
        }
        
        // Set up periodic status checks
        statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.updateSubscriptionStatus()
            }
        }
    }
    
    deinit {
        transactionListener?.cancel()
        statusUpdateTimer?.invalidate()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            // Iterate through any transactions that don't have a revocation status
            for await result in Transaction.updates {
                do {
                    let transaction = try await self?.checkVerified(result)
                    
                    // Update the customer's subscription status
                    await self?.updateSubscriptionStatus()
                    
                    // Always finish a transaction
                    await transaction?.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this subscription is still valid
                if transaction.revocationDate == nil {
                    hasActiveSubscription = true
                    break
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        // Update the status
        await MainActor.run {
            self.subscriptionStatus = hasActiveSubscription ? .subscribed : .notSubscribed
        }
    }
    
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: [subscriptionGroupID])
            
            await MainActor.run {
                self.subscriptions = storeProducts.sorted(by: { $0.price < $1.price })
            }
        } catch {
            print("Failed to request products:", error)
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        // Begin purchasing the product
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
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
    
    func restorePurchases() async throws {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    var hasActiveSubscription: Bool {
        subscriptionStatus == .subscribed
    }
}

enum StoreError: Error {
    case failedVerification
    case unknownError
}
