//
//  GenerateRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//

import SwiftUI
import SwiftData

struct GenerateRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("OPENAI_API_KEY") private var apiKey = ""
    
    @State private var prompt = ""
    @State private var isGenerating = false
    @State private var error: Error?
    @State private var showingError = false
    @State private var generatedRecipe: Recipe?
    
    private let suggestions = [
        "A healthy vegetarian pasta dish",
        "A spicy Asian stir-fry",
        "An easy 30-minute weeknight dinner",
        "A traditional Italian dessert",
        "A protein-rich breakfast bowl"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                if apiKey.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("OpenAI API Key Required")
                                .font(.headline)
                            Text("To generate recipes using AI, you need to set up your OpenAI API key in Settings.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    Section {
                        Text("You can use AI to generate a recipe for you. For this to work, you must set up your OpenAI API key in Settings.")
                    }
                    Section {
                        TextField("Describe the recipe you want", text: $prompt, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    
                    Section("Suggestions") {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                prompt = suggestion
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                    if let recipe = generatedRecipe {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recipe.name)
                                    .font(.headline)
                                Text(recipe.recipeDescription)
                                    .font(.subheadline)
                                HStack {
                                    TimeChip(minutes: recipe.cookingTimeMinutes)
                                    DifficultyChip(recipe: recipe)
                                }
                            }
                        }
                        
                        Section("Actions") {
                            Button("Save Recipe") {
                                modelContext.insert(recipe)
                                dismiss()
                            }
                            Button("Generate Another") {
                                generatedRecipe = nil
                            }
                        }
                    } else {
                        Section {
                            Button(action: generateRecipe) {
                                if isGenerating {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Generate Recipe")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .disabled(prompt.isEmpty || isGenerating)
                        }
                    }
                }
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
        }
    }
    
    private func generateRecipe() {
        isGenerating = true
        error = nil
        
        Task {
            do {
                let service = AIRecipeService(apiKey: apiKey)
                let recipe = try await service.generateRecipe(prompt: prompt)
                
                await MainActor.run {
                    generatedRecipe = recipe
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
