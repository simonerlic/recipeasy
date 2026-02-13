//
//  Recipe.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//
//  Type aliases for the current schema version
//  This allows existing code to work without changes
//

import Foundation
import SwiftData

// Type aliases pointing to the current schema version (V2)
typealias Recipe = RecipeSchemaV2.Recipe
typealias Ingredient = RecipeSchemaV2.Ingredient
typealias CookingStep = RecipeSchemaV2.CookingStep
typealias RecipeAttempt = RecipeSchemaV2.RecipeAttempt
typealias DifficultyLevel = RecipeSchemaV2.DifficultyLevel

// Note: Category is not aliased here because it has its own file
// The extensions for Hashable are already defined in RecipeSchemaV2.swift
