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
                                        .font(.title3.bold())
                                    Text("Generate unlimited AI recipes without an API key")
                                        .font(.caption)
                                        .padding(.top, 4)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Thanks for subscribing!")
                                    .font(.title3.bold())
                                Text("You can manage your subscription within the App Store.")
                                    .font(.caption)
                                    .padding(.top, 4)
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
                    
                    Section(header: Text("Legal")) {
                        Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                            HStack {
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.freeprivacypolicy.com/live/e16560bd-109e-4dc2-a9d0-0fd8b28077ea")!) {
                            HStack {
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                        }
                    }
                
                    Section {
                        Label("Version 1.1.0", systemImage: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("Made with ❤️ by Simon")
                    .font(.footnote)
                    .padding(.vertical)
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
