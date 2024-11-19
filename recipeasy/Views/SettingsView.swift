//
//  SettingsView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("OPENAI_API_KEY") private var apiKey = ""
    @State private var showingApiKey = false
    @State private var showingSubscription = false
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        NavigationStack {
            VStack{
                Form {
                    Section {
                        if !subscriptionService.hasActiveSubscription {
                            Button(action: { showingSubscription = true }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Subscribe to Recipeasy")
                                        .font(.headline)
                                    Text("Generate unlimited AI recipes without an API key")
                                        .font(.caption)
                                        .padding(.top, 4)
                                }
                            }
                        }
                    }
                    
                    if !subscriptionService.hasActiveSubscription {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                if showingApiKey {
                                    TextField("OpenAI API Key", text: $apiKey)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                } else {
                                    SecureField("OpenAI API Key", text: $apiKey)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                
                                Toggle("Show API Key", isOn: $showingApiKey)
                                    .toggleStyle(.switch)
                                
                                Link("Get an API key", destination: URL(string: "https://platform.openai.com/api-keys")!)
                                    .font(.caption)
                            }
                        } footer: {
                            Text("Required for AI recipe generation if you're not subscribed. Your API key is stored securely on your device.")
                        }
                    }
                    
                    Section {
                        Label("Version 1.0.0", systemImage: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("Made with ❤️ by Simon")
                    .font(.footnote)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
        }
    }
}
