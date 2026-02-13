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
    @AppStorage("OPENAI_API_KEY", store: UserDefaults(suiteName: "group.dev.serlic.recipeasy"))
    private var apiKey = ""
    @AppStorage("AI_PROVIDER", store: UserDefaults(suiteName: "group.dev.serlic.recipeasy"))
    private var selectedProvider: String = AIProviderType.openai.rawValue

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

                // AI Provider Selection
                Section {
                    Picker("AI Provider", selection: Binding(
                        get: { AIProviderType(rawValue: selectedProvider) ?? .appleIntelligence },
                        set: { selectedProvider = $0.rawValue }
                    )) {
                        ForEach(AIProviderType.allCases, id: \.self) { provider in
                            VStack(alignment: .leading) {
                                Text(provider.displayName)
                                    .tag(provider)
                            }
                        }
                    }
                    .pickerStyle(.menu)

                    // Show provider description
                    if let providerType = AIProviderType(rawValue: selectedProvider) {
                        Text(providerType.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Show warning if Apple Intelligence is selected but not available
                    if selectedProvider == AIProviderType.appleIntelligence.rawValue {
                        #if canImport(FoundationModels)
                        if #available(iOS 26.0, *) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Apple Intelligence is available on this device")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text("Apple Intelligence requires iOS 26.0 or later. Please select OpenAI.")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        #else
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Apple Intelligence requires iOS 26.0 or later")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text("Available from June 2025. Please select OpenAI for now.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        #endif
                    }
                } header: {
                    Text("AI Generation")
                } footer: {
                    Text("Choose which AI service to use for recipe generation. Apple Intelligence runs on-device and doesn't require an API key.")
                }

                if !subscriptionService.hasActiveSubscription && selectedProvider == AIProviderType.openai.rawValue {
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
                
                
                
                // Version info section
                Section {
                    VStack(alignment: .center, spacing: 4) {
                        Text("Version 1.4.0")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("Made with ❤️ by Simon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
