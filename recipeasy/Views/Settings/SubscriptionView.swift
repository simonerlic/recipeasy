//
//  SubscriptionView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingOfferCode = false

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                        
                        Text("Unlock AI Recipe Generation")
                            .font(.title2.bold())
                    }
                    .padding(.top)
                    
                    // Subscription Options
                    VStack(spacing: 16) {
                        ForEach(subscriptionService.subscriptions, id: \.id) { product in
                            SubscriptionOption(
                                product: product,
                                isSelected: selectedProduct?.id == product.id,
                                onSelect: { selectedProduct = product }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's included:")
                            .font(.headline)
                        
                        FeatureRow(icon: "sparkles", text: "Generate unlimited AI recipes")
                        FeatureRow(icon: "key.fill", text: "No API key required")
                        FeatureRow(icon: "wand.and.stars", text: "Access to premium recipe templates")
                        FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Free updates")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Subscribe Button
                    Button(action: purchase) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(subscriptionButtonText)
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .disabled(selectedProduct == nil || isPurchasing)
                    .opacity(selectedProduct == nil ? 0.6 : 1.0)
                    
                    Button(action: {
                        Task {
                            do {
                                try await subscriptionService.restorePurchases()
                                if subscriptionService.hasActiveSubscription {
                                    dismiss()
                                }
                            } catch {
                                errorMessage = "Failed to restore purchases"
                                showError = true
                            }
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    OfferCodeButton(isShowingOfferCode: $showingOfferCode)
                }
            }
            .navigationTitle("Subscribe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingOfferCode) {
                OfferCodeView()
            }
        }
    }
    
    private var subscriptionButtonText: String {
        if let product = selectedProduct {
            return "Subscribe for \(product.displayPrice)"
        }
        return "Select a Plan"
    }
    
    private func purchase() {
        guard let product = selectedProduct else { return }
        
        Task {
            isPurchasing = true
            defer { isPurchasing = false }
            
            do {
                if let transaction = try await subscriptionService.purchase(product) {
                    print("Successfully purchased: \(transaction.productID)")
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct SubscriptionOption: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.headline)
                
                Text("/ mo")
                    .font(.subheadline)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
            Spacer()
        }
    }
}
