import SwiftUI
import Foundation

public enum APIEnv {
    enum Keys {
        static let apiKey = "OPENAI_API_KEY"
    }

    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found" )
        }
        return dict
    } ()

    static let apiKey: String = {
        guard let apiKeyString = APIEnv.infoDictionary[Keys.apiKey] as?
                String else {
            fatalError("API Key not set in plist")
        }
        return apiKeyString
    }()
    
}

struct GenerateRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("OPENAI_API_KEY") private var userApiKey = ""
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var prompt = ""
    @State private var isGenerating = false
    @State private var error: Error?
    @State private var showingError = false
    @State private var generatedRecipe: Recipe?
    @State private var selectedSuggestion: String?
    @State private var showingSubscription = false
    
    private let suggestions = [
        (icon: "🍝", text: "A healthy vegetarian pasta dish", color: Color.green),
        (icon: "🥘", text: "A spicy Asian stir-fry", color: Color.red),
        (icon: "🍳", text: "An easy 30-minute weeknight dinner", color: Color.orange),
        (icon: "🍰", text: "A traditional Italian dessert", color: Color.purple),
        (icon: "🥗", text: "A protein-rich breakfast bowl", color: Color.blue)
    ]
    
    private let subscriberApiKey = APIEnv.apiKey
    
    private var activeApiKey: String {
        subscriptionService.hasActiveSubscription ? subscriberApiKey : userApiKey
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !subscriptionService.hasActiveSubscription && userApiKey.isEmpty {
                        setupRequiredView
                    } else {
                        if let recipe = generatedRecipe {
                            recipeResultView(recipe)
                        } else {
                            promptInputSection
                            suggestionsSection
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("AI Recipe Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", action: {})
            } message: {
                Text(error?.localizedDescription ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
        }
    }
    
    private var setupRequiredView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(Circle())
            
            Text("AI Generation Setup Required")
                .font(.title2.bold())
            
            Text("To use the AI recipe generator, you'll need to either subscribe or provide your own OpenAI API key.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                Button {
                    showingSubscription = true
                } label: {
                    Label("Subscribe Now", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    dismiss()
                } label: {
                    Label("Use My Own API Key", systemImage: "key")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    private var promptInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What would you like to cook?", systemImage: "wand.and.stars")
                .font(.headline)
            
            TextField("Describe your ideal recipe...", text: $prompt, axis: .vertical)
                .lineLimit(1...6)
                .disabled(isGenerating)
            
            if !prompt.isEmpty {
                generateButton
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: !prompt.isEmpty)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Need inspiration?", systemImage: "lightbulb.fill")
                .font(.headline)
            
            VStack(spacing: 10) {
                ForEach(suggestions, id: \.text) { suggestion in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSuggestion = suggestion.text
                            prompt = suggestion.text
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(suggestion.icon)
                                .font(.title2)
                            
                            Text(suggestion.text)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .opacity(selectedSuggestion == suggestion.text ? 1 : 0)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(suggestion.color.opacity(selectedSuggestion == suggestion.text ? 0.15 : 0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(suggestion.color.opacity(selectedSuggestion == suggestion.text ? 0.3 : 0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    
    private var generateButton: some View {
        Button(action: generateRecipe) {
            if isGenerating {
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Generating recipe...")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Label("Generate Recipe", systemImage: "wand.and.stars")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .disabled(prompt.isEmpty || isGenerating)
    }
    
    @ViewBuilder
    private func recipeResultView(_ recipe: Recipe) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
                .padding()
            
            Text("Recipe Generated!")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.name)
                    .font(.title3.bold())
                
                Text(recipe.recipeDescription)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Label("\(recipe.cookingTimeMinutes) min", systemImage: "clock")
                    Spacer()
                    Label(recipe.difficulty.rawValue, systemImage: "chart.bar.fill")
                }
                .foregroundStyle(.secondary)
                .font(.callout)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 16) {
                Button(action: { generatedRecipe = nil }) {
                    Label("Try Again", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    modelContext.insert(recipe)
                    // Delay the dismiss to allow confetti to show
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                } label: {
                    Label("Save Recipe", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    
    private func generateRecipe() {
        isGenerating = true
        error = nil
        
        Task {
            do {
                let service = AIRecipeService(apiKey: activeApiKey)
                let recipe = try await service.generateRecipe(prompt: prompt)
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        generatedRecipe = recipe
                    }
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.showingError = true
                    self.isGenerating = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GenerateRecipeView()
    }
}
