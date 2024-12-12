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
            Form {
                // Subscription Section
                Section {
                    if !subscriptionService.hasActiveSubscription {
                        Button(action: { showingSubscription = true }) {
                            HStack(spacing: 16) {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.purple)
                                    .frame(width: 48, height: 48)
                                    .background(.purple.opacity(0.1))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Subscribe to Recipeasy")
                                        .font(.headline)
                                    Text("Generate unlimited AI recipes")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.green)
                                .frame(width: 48, height: 48)
                                .background(.green.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Subscription is Active")
                                    .font(.headline)
                                Text("Thanks for supporting the app!")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } footer: {
                    Text("Please manage your subscription in the App Store")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if !subscriptionService.hasActiveSubscription {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Group {
                                    if showingApiKey {
                                        TextField("OpenAI API Key", text: $apiKey)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                    } else {
                                        SecureField("OpenAI API Key", text: $apiKey)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                    }
                                }
                                
                                Button(action: { showingApiKey.toggle() }) {
                                    Image(systemName: showingApiKey ? "eye.fill" : "eye.slash.fill")
                                        .foregroundStyle(.blue)
                                        .frame(width: 24, height: 24)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .cornerRadius(8)
                            
                            Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                                Text("Get an API key")
                                    .font(.subheadline)
                            }
                        }
                    } header: {
                        Text("API Configuration")
                    } footer: {
                        Text("Required for AI recipe generation if you're not subscribed. Your API key is stored securely on your device.")
                    }
                }
                
                // Legal Section
                Section {
                    ForEach([
                        ("Terms of Service", "doc.text", "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
                        ("Privacy Policy", "hand.raised.fill", "https://www.freeprivacypolicy.com/live/e16560bd-109e-4dc2-a9d0-0fd8b28077ea")
                    ], id: \.0) { title, icon, urlString in
                        Link(destination: URL(string: urlString)!) {
                            HStack {
                                Label(title, systemImage: icon)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                
                
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .padding(.top)
            
            VStack(alignment: .center) {
                Text("Version 1.2.0")
                    .font(.caption2)
                Text("Made with ❤️ by Simon")
                    .font(.caption)
            }
        }
    }
}

#Preview {
    SettingsView()
}
