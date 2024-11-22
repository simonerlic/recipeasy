//
//  OfferCodeButton.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-22.
//

import SwiftUI
import StoreKit

struct OfferCodeButton: View {
    @Binding var isShowingOfferCode: Bool
    
    var body: some View {
        Button(action: { isShowingOfferCode = true }) {
            Text("Have a subscription code?")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
        .padding(.top)
    }
}

struct OfferCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        NavigationStack {
            SubscriptionStoreView(groupID: subscriptionService.subscriptionGroupID)
                .navigationTitle("Redeem Code")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
