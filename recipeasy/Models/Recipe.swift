//
//  Recipe.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//


// Recipe.swift
import Foundation
import SwiftData

@Model
final class Recipe {
    var name: String
    var recipeDescription: String
    var ingredients: [Ingredient]
    var steps: [CookingStep]
    var cookingTimeMinutes: Int
    var difficulty: DifficultyLevel
    var tags: [String]
    var notes: String
    var isAIGenerated: Bool
    var dateCreated: Date
    var dateModified: Date
    
    init(
            name: String = "",
            recipeDescription: String = "",
            ingredients: [Ingredient] = [],
            steps: [CookingStep] = [],
            cookingTimeMinutes: Int = 0,
            difficulty: DifficultyLevel = .medium,
            tags: [String] = [],
            notes: String = "",
            isAIGenerated: Bool = false
        ) {
            self.name = name
            self.recipeDescription = recipeDescription
            self.ingredients = ingredients
            self.steps = steps
            self.cookingTimeMinutes = cookingTimeMinutes
            self.difficulty = difficulty
            self.tags = tags
            self.notes = notes
            self.isAIGenerated = isAIGenerated
            let now = Date()
            self.dateCreated = now
            self.dateModified = now
            
            // Initialize relationships
            ingredients.forEach { $0.recipe = self }
            steps.forEach { $0.recipe = self }
        }
}

@Model
final class Ingredient {
    var name: String
    var amount: Double
    var unit: String
    var notes: String?
    var recipe: Recipe?
    
    init(name: String = "", amount: Double = 0.0, unit: String = "", notes: String? = nil) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.notes = notes
    }
}

@Model
final class CookingStep {
    var orderIndex: Int
    var stepDescription: String
    var durationMinutes: Int?
    var notes: String?
    var recipe: Recipe?
    
    init(orderIndex: Int = 0, stepDescription: String = "", durationMinutes: Int? = nil, notes: String? = nil) {
        self.orderIndex = orderIndex
        self.stepDescription = stepDescription
        self.durationMinutes = durationMinutes
        self.notes = notes
    }
}

enum DifficultyLevel: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}