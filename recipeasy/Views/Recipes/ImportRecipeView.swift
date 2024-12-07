//
//  ImportRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-20.
//

import SwiftUI

import SwiftUI

struct ImportRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("OPENAI_API_KEY") private var userApiKey = ""
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var url = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingError = false
    @State private var showingSubscription = false
    @State private var showingSettings = false
    @State private var showingPasteConfirmation = false
    
    private let subscriberApiKey = APIEnv.apiKey
    
    private var activeApiKey: String {
        subscriptionService.hasActiveSubscription ? subscriberApiKey : userApiKey
    }
    
    var body: some View {
        NavigationStack {
            if !subscriptionService.hasActiveSubscription && userApiKey.isEmpty {
                APISetupView(
                    showingSettings: $showingSettings,
                    showingSubscription: $showingSubscription
                )
                .navigationTitle("Setup Required")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section with icon and description
                        VStack(spacing: 16) {
                            Image(systemName: "link")
                                .font(.system(size: 40))
                                .foregroundStyle(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Found a recipe you love? Paste the URL below and we'll import it into your collection.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // URL input section
                        VStack(spacing: 12) {
                            HStack {
                                TextField("Recipe URL", text: $url)
                                    .padding(8)
                                    .padding(.leading, 8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Capsule())
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .disabled(isLoading)
                                
                                Button(action: pasteFromClipboard) {
                                    Label("Paste", systemImage: "doc.on.clipboard")
                                        .labelStyle(.iconOnly)
                                        .padding(8)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                            
                            if isLoading {
                                ProgressView("Importing recipe...")
                                    .padding(.top)
                            }
                        }
                        
                        // Supported websites section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Supported Websites")
                                .font(.headline)
                            
                            Text("We support importing from most popular recipe websites, including:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                SupportedWebsiteLabel(name: "AllRecipes")
                                SupportedWebsiteLabel(name: "Food Network")
                                SupportedWebsiteLabel(name: "Epicurious")
                                SupportedWebsiteLabel(name: "BBC Good Food")
                                SupportedWebsiteLabel(name: "Simply Recipes")
                                SupportedWebsiteLabel(name: "Tasty")
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Import Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Import") {
                    Task {
                        await importRecipe()
                    }
                }
                .disabled(url.isEmpty || isLoading || (!subscriptionService.hasActiveSubscription && userApiKey.isEmpty))
            }
        }
        .sheet(isPresented: $showingSubscription) {
            NavigationStack {
                SubscriptionView()
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .alert("Import Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
        .alert("Paste URL?", isPresented: $showingPasteConfirmation) {
            Button("Paste", role: .destructive) {
                url = UIPasteboard.general.string ?? ""
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to paste: \n\n\(UIPasteboard.general.string ?? "")")
        }
    }
    
    private func pasteFromClipboard() {
        guard let clipboardString = UIPasteboard.general.string, !clipboardString.isEmpty else { return }
        
        if clipboardString.contains("http") {
            showingPasteConfirmation = true
        } else {
            url = clipboardString
        }
    }
    
    private func importRecipe() async {
        guard let url = URL(string: url) else {
            error = URLRecipeError.invalidURL
            showingError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch HTML
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else {
                throw URLRecipeError.parsingError
            }
            
            // Parse with LLM
            let service = ParseWebRecipeService(apiKey: activeApiKey)
            let recipe = try await service.parseRecipeFromHTML(html)
            
            // Save recipe
            modelContext.insert(recipe)
            dismiss()
        } catch {
            self.error = error
            showingError = true
        }
    }
}

struct SupportedWebsiteLabel: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}

enum URLRecipeError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case parsingError
    case unsupportedWebsite
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid recipe URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsingError:
            return "Unable to parse recipe from website"
        case .unsupportedWebsite:
            return "This website is not currently supported"
        }
    }
}

#Preview {
    ImportRecipeView()
}
