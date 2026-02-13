//
//  AppleIntelligenceProvider.swift
//  recipeasy
//
//  Apple Intelligence implementation using Foundation Models framework
//  Requires iOS 26.0+ (Available from June 2025 / WWDC 2025)
//
//  NOTE: This implementation uses the Foundation Models framework which requires:
//  - iOS 26.0+ / iPadOS 26.0+ / macOS 26.0+
//  - Xcode 17.0+ with iOS 26 SDK
//
//  If you don't have iOS 26 SDK yet, this provider will be unavailable
//  and users will need to use OpenAI provider instead.
//

import Foundation

// Conditional import - only available on iOS 26+
#if canImport(FoundationModels)
import FoundationModels
#endif

class AppleIntelligenceProvider: AIProvider {
    var name: String {
        "Apple Intelligence"
    }

    var isAvailable: Bool {
        // Check if Foundation Models is available on this device
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            return true
        }
        #endif
        return false
    }

    func generateRecipe(prompt: String) async throws -> Recipe {
        #if canImport(FoundationModels)
        guard #available(iOS 26.0, macOS 26.0, *) else {
            throw AIProviderError.unsupportedOnDevice
        }

        do {
            // Create a session with instructions for recipe generation
            let session = LanguageModelSession(instructions: """
                You are a helpful cooking assistant. Generate detailed recipes with exact measurements, \
                step-by-step instructions, difficulty ratings, and cooking tips. \
                Ensure all measurements are precise with numeric values. \
                Keep step descriptions clear and concise. \
                Include relevant cooking tips in the notes field. \
                Set the difficulty level accordingly: "Easy" for quick and beginner friendly recipes, \
                "Medium" for achievable home chef recipes, and "Hard" for fairly difficult or lengthy recipes.
                """)

            // Generate structured recipe output using @Generable
            let response = try await session.respond(generating: AppleRecipeResponse.self) {
                prompt
            }

            // Convert AppleRecipeResponse to Recipe model
            return convertToRecipe(response.content)

        } catch {
            // Handle specific Foundation Models errors
            throw AIProviderError.apiError("Apple Intelligence error: \(error.localizedDescription)")
        }
        #else
        // Foundation Models not available - throw error
        throw AIProviderError.unsupportedOnDevice
        #endif
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    private func convertToRecipe(_ response: AppleRecipeResponse) -> Recipe {
        let ingredients = response.ingredients.map { ingredient in
            Ingredient(
                name: ingredient.name,
                amount: ingredient.amount,
                unit: ingredient.unit,
                notes: ingredient.notes
            )
        }

        let steps = response.steps.enumerated().map { index, step in
            CookingStep(
                orderIndex: index,
                stepDescription: step.description,
                durationMinutes: step.durationMinutes,
                notes: step.notes
            )
        }

        let difficulty: DifficultyLevel
        switch response.difficulty.lowercased() {
        case "easy":
            difficulty = .easy
        case "hard":
            difficulty = .hard
        default:
            difficulty = .medium
        }

        return Recipe(
            name: response.name,
            recipeDescription: response.description,
            ingredients: ingredients,
            steps: steps,
            cookingTimeMinutes: response.cookingTimeMinutes,
            difficulty: difficulty,
            notes: response.notes,
            isAIGenerated: true
        )
    }
    #endif
}

// MARK: - @Generable Response Structures
// Only compile these if Foundation Models is available

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct AppleRecipeResponse {
    @Guide(description: "The name of the recipe")
    let name: String

    @Guide(description: "A detailed description of the recipe")
    let description: String

    @Guide(description: "Cooking time in minutes", .range(1...1440))
    let cookingTimeMinutes: Int

    @Guide(description: "Difficulty level: Easy, Medium, or Hard")
    let difficulty: String

    let ingredients: [AppleIngredient]
    let steps: [AppleStep]

    @Guide(description: "Helpful cooking tips and notes")
    let notes: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct AppleIngredient {
    @Guide(description: "Name of the ingredient")
    let name: String

    @Guide(description: "Amount of the ingredient", .range(0...1000))
    let amount: Double

    @Guide(description: "Unit of measurement (e.g., cups, tablespoons, grams)")
    let unit: String

    @Guide(description: "Optional notes about the ingredient")
    let notes: String?
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct AppleStep {
    @Guide(description: "Step-by-step instruction")
    let description: String

    @Guide(description: "Duration of this step in minutes (optional)", .range(1...240))
    let durationMinutes: Int?

    @Guide(description: "Optional notes for this step")
    let notes: String?
}
#endif
