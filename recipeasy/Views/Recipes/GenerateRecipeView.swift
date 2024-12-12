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
    @State private var showingSubscription = false
    @State private var showingSettings = false
    
    @State private var showPreferences = false
    @State private var preferences = RecipePreferences()
    
    @State private var currentSuggestions: [QuickSuggestion] = []
    
    private let subscriberApiKey = APIEnv.apiKey
    
    private var activeApiKey: String {
        switch subscriptionService.subscriptionStatus {
        case .subscribed:
            return subscriberApiKey
        case .notSubscribed:
            return userApiKey
        case .unknown:
            Task {
                await subscriptionService.updateSubscriptionStatus()
            }
            return userApiKey.isEmpty ? subscriberApiKey : userApiKey
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if subscriptionService.subscriptionStatus == .notSubscribed && userApiKey.isEmpty {
                        APISetupView(
                            showingSettings: $showingSettings,
                            showingSubscription: $showingSubscription
                        )
                        .navigationTitle("Setup Required")
                    } else {
                        if let recipe = generatedRecipe {
                            recipeResultView(recipe)
                        } else {
                            promptBuilderView
                            quickSuggestionsView
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
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? "An unknown error occurred")
            }
        }
        .task {
            await subscriptionService.updateSubscriptionStatus()
        }
    }
    
    private var promptBuilderView: some View {
        VStack(spacing: 16) {
            // Main prompt input card
            VStack(spacing: 16) {
                promptHeader
                promptInput
                preferencesToggle
                
                if showPreferences {
                    preferencesSection
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Generate button
            if !prompt.isEmpty {
                generateButton
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: !prompt.isEmpty)
            }
        }
    }
    
    private var promptHeader: some View {
        HStack {
            Image(systemName: "wand.and.stars")
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text("What would you like to cook?")
                .font(.headline)
            
            Spacer()
        }
    }
    
    private var promptInput: some View {
        TextField("Describe your ideal recipe...", text: $prompt, axis: .vertical)
            .lineLimit(1...6)
            .disabled(isGenerating)
    }
    
    private var preferencesToggle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showPreferences.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(showPreferences ? 90 : 0))
                Text(showPreferences ? "Hide options" : "Show options")
                Spacer()
            }
            .foregroundStyle(.primary)
            .font(.subheadline)
        }
    }
    
    private var preferencesSection: some View {
        VStack(spacing: 16) {
            // Dietary Restrictions
            VStack(alignment: .leading, spacing: 8) {
                Label("Dietary Restrictions", systemImage: "scale.3d")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DietaryRestriction.allCases) { restriction in
                            Toggle(restriction.label, isOn: Binding(
                                get: { preferences.dietaryRestrictions.contains(restriction.id) },
                                set: { isOn in
                                    if isOn {
                                        preferences.dietaryRestrictions.insert(restriction.id)
                                    } else {
                                        preferences.dietaryRestrictions.remove(restriction.id)
                                    }
                                }
                            ))
                            .toggleStyle(ChipToggleStyle())
                        }
                    }
                }
            }
            
            // Cooking Time
            VStack(alignment: .leading, spacing: 8) {
                Label("Cooking Time", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CookingTimePreference.allCases, id: \.self) { time in
                            Toggle(time.rawValue, isOn: Binding(
                                get: { preferences.cookingTime == time },
                                set: { isOn in
                                    if isOn {
                                        preferences.cookingTime = time
                                    }
                                }
                            ))
                            .toggleStyle(ChipToggleStyle())
                        }
                    }
                }
            }
            
            // Cuisine Type
            VStack(alignment: .leading, spacing: 8) {
                Label("Cuisine", systemImage: "book")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CuisinePreference.allCases, id: \.self) { cuisine in
                            Toggle(cuisine.rawValue, isOn: Binding(
                                get: { preferences.cuisine == cuisine },
                                set: { isOn in
                                    if isOn {
                                        preferences.cuisine = cuisine
                                    }
                                }
                            ))
                            .toggleStyle(ChipToggleStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var quickSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Suggestions")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                ForEach(currentSuggestions) { suggestion in
                    Button {
                        preferences = suggestion.preferences
                        prompt = suggestion.text
                        
                        withAnimation {
                            showPreferences = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(suggestion.emoji)
                                .font(.title2)
                            
                            Text(suggestion.text)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .onAppear {
            // Rotate suggestions when view appears
            currentSuggestions = QuickSuggestion.getRandomSuggestions()
        }
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
        // Success checkmark animation
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(.green)
            .padding()
        
        Text("Recipe Generated!")
            .font(.title.bold())
        
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
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        
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
                // Delay the dismiss to allow animation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 16))
}

private func generateRecipe() {
        isGenerating = true
        error = nil
        
        // Combine preferences with the prompt
        let fullPrompt = preferences.buildPromptPrefix() + prompt
        
        Task {
            do {
                await subscriptionService.updateSubscriptionStatus()
                
                let service = AIRecipeService(apiKey: activeApiKey)
                let recipe = try await service.generateRecipe(prompt: fullPrompt)
                
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

struct ChipToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(configuration.isOn ? Color.blue : Color(.systemGray5))
            .foregroundStyle(configuration.isOn ? .white : .primary)
            .clipShape(Capsule())
            .animation(.snappy, value: configuration.isOn)
        }
    }
}

#Preview {
    NavigationStack {
        GenerateRecipeView()
    }
}
