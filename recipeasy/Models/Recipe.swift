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
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade, inverse: \RecipeAttempt.recipe) var attempts: [RecipeAttempt]
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe) var ingredients: [Ingredient]
    @Relationship(deleteRule: .cascade, inverse: \CookingStep.recipe) var steps: [CookingStep]
    
    var name: String
    var recipeDescription: String
    var cookingTimeMinutes: Int
    var difficulty: DifficultyLevel
    var notes: String
    var isAIGenerated: Bool
    var dateCreated: Date
    var dateModified: Date
    var imageData: Data?
    
    var hasImage: Bool { imageData != nil }
    
    init(
        id: UUID = UUID(), // Provide default value
        name: String = "",
        recipeDescription: String = "",
        ingredients: [Ingredient] = [],
        steps: [CookingStep] = [],
        cookingTimeMinutes: Int = 0,
        difficulty: DifficultyLevel = .medium,
        notes: String = "",
        isAIGenerated: Bool = false,
        imageData: Data? = nil,
        attempts: [RecipeAttempt] = []
    ) {
        self.id = id
        self.name = name
        self.recipeDescription = recipeDescription
        self.ingredients = ingredients
        self.steps = steps
        self.cookingTimeMinutes = cookingTimeMinutes
        self.difficulty = difficulty
        self.notes = notes
        self.isAIGenerated = isAIGenerated
        self.imageData = imageData
        self.attempts = attempts
        let now = Date()
        self.dateCreated = now
        self.dateModified = now
    }
}

@Model
final class Ingredient {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var unit: String
    var notes: String?
    var recipe: Recipe?
    
    init(
        id: UUID = UUID(), // Provide default value
        name: String = "",
        amount: Double = 0.0,
        unit: String = "",
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.notes = notes
    }
}

@Model
final class CookingStep {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int
    var stepDescription: String
    var durationMinutes: Int?
    var notes: String?
    var recipe: Recipe?
    var imageData: Data?
    
    var hasImage: Bool { imageData != nil }
    
    init(
        id: UUID = UUID(), // Provide default value
        orderIndex: Int = 0,
        stepDescription: String = "",
        durationMinutes: Int? = nil,
        notes: String? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.stepDescription = stepDescription
        self.durationMinutes = durationMinutes
        self.notes = notes
        self.imageData = imageData
    }
}

@Model
final class RecipeAttempt {
    @Attribute(.unique) var id: UUID
    var recipe: Recipe?
    var dateCreated: Date
    var notes: String
    var imageData: Data?
    var rating: Int?
    
    init(
        id: UUID = UUID(), // Provide default value
        recipe: Recipe? = nil,
        notes: String = "",
        imageData: Data? = nil,
        rating: Int? = nil
    ) {
        self.id = id
        self.recipe = recipe
        self.notes = notes
        self.imageData = imageData
        self.rating = rating
        self.dateCreated = Date()
    }
}

enum DifficultyLevel: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

extension Ingredient: Hashable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CookingStep: Hashable {
    static func == (lhs: CookingStep, rhs: CookingStep) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
