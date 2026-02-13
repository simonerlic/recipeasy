//
//  RecipeSchemaV1.swift
//  recipeasy
//
//  NOTE: This file is not currently used and is kept for reference only.
//
//  The app originally used an unversioned schema, and we're migrating directly
//  to RecipeSchemaV2 (version 1.0.0) to add versioning support.
//
//  This file can be deleted or kept for documentation purposes.
//

import Foundation
import SwiftData

enum RecipeSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(0, 9, 0)

    static var models: [any PersistentModel.Type] {
        [Recipe.self, Ingredient.self, CookingStep.self, RecipeAttempt.self, Category.self]
    }

    @Model
    final class Recipe {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .cascade, inverse: \RecipeAttempt.recipe) var attempts: [RecipeAttempt]
        @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe) var ingredients: [Ingredient]
        @Relationship(deleteRule: .cascade, inverse: \CookingStep.recipe) var steps: [CookingStep]
        var categories: [Category]

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
            id: UUID = UUID(),
            name: String = "",
            recipeDescription: String = "",
            ingredients: [Ingredient] = [],
            steps: [CookingStep] = [],
            cookingTimeMinutes: Int = 0,
            difficulty: DifficultyLevel = .medium,
            notes: String = "",
            isAIGenerated: Bool = false,
            imageData: Data? = nil,
            attempts: [RecipeAttempt] = [],
            categories: [Category] = []
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
            self.categories = categories
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
            id: UUID = UUID(),
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
        var isCompleted: Bool

        var hasImage: Bool { imageData != nil }

        init(
            id: UUID = UUID(),
            orderIndex: Int = 0,
            stepDescription: String = "",
            durationMinutes: Int? = nil,
            notes: String? = nil,
            imageData: Data? = nil,
            isCompleted: Bool = false
        ) {
            self.id = id
            self.orderIndex = orderIndex
            self.stepDescription = stepDescription
            self.durationMinutes = durationMinutes
            self.notes = notes
            self.imageData = imageData
            self.isCompleted = isCompleted
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
            id: UUID = UUID(),
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

    @Model
    final class Category {
        @Attribute(.unique) var id: UUID
        var name: String
        var dateCreated: Date
        var sortOrder: Int
        @Relationship(deleteRule: .nullify, inverse: \Recipe.categories) var recipes: [Recipe]

        init(
            id: UUID = UUID(),
            name: String = "",
            sortOrder: Int = 0,
            recipes: [Recipe] = []
        ) {
            self.id = id
            self.name = name
            self.sortOrder = sortOrder
            self.recipes = recipes
            self.dateCreated = Date()
        }

        func save(context: ModelContext) throws {
            try context.save()
        }
    }

    enum DifficultyLevel: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}

// MARK: - Hashable Extensions
extension RecipeSchemaV1.Ingredient: Hashable {
    static func == (lhs: RecipeSchemaV1.Ingredient, rhs: RecipeSchemaV1.Ingredient) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension RecipeSchemaV1.CookingStep: Hashable {
    static func == (lhs: RecipeSchemaV1.CookingStep, rhs: RecipeSchemaV1.CookingStep) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
