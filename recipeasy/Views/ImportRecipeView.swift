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
    @AppStorage("OPENAI_API_KEY") private var apiKey = ""
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var url = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingError = false
    @State private var showingSubscription = false
    
    private var activeApiKey: String {
        subscriptionService.hasActiveSubscription ? "your-api-key-here" : apiKey
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if !subscriptionService.hasActiveSubscription && apiKey.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Setup Required")
                                .font(.headline)
                            Text("To import recipes from URLs, you'll need to either subscribe or provide your own OpenAI API key.")
                            
                            Button(action: { showingSubscription = true }) {
                                Label("Subscribe Now", systemImage: "star.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
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
                    .disabled(url.isEmpty || isLoading || (!subscriptionService.hasActiveSubscription && apiKey.isEmpty))
                }
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
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
