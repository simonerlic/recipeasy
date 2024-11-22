//
//  ImportRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-20.
//

import SwiftUI

struct ImportRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("OPENAI_API_KEY") private var userApiKey = ""
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var url = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingError = false
    @State private var showingSubscription = false
    @State private var showingSettings = false
    
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            } else {
                Form {
                    Section {
                        TextField("Recipe URL", text: $url)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(isLoading)
                    } footer: {
                        Text("Enter the URL of a recipe you'd like to import")
                    }
                    
                    if isLoading {
                        Section {
                            HStack {
                                Spacer()
                                ProgressView("Importing recipe...")
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            Spacer()
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
