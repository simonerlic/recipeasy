//
//  AIResponse.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//


struct AIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct AIRecipeData: Codable {
    let name: String
    let description: String
    let cookingTimeMinutes: Int
    let difficulty: String
    let ingredients: [AIIngredient]
    let steps: [AIStep]
    let notes: String
    
    struct AIIngredient: Codable {
        let name: String
        let amount: Double
        let unit: String
        let notes: String?
    }
    
    struct AIStep: Codable {
        let orderIndex: Int
        let description: String
        let durationMinutes: Int?
        let notes: String?
    }
}
