//
//  RecipeShareManager.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-19.
//

import SwiftUI

struct RecipeShareManager {
    static let scheme = "recipeasy"
    static let host = "recipe"
    
    // Create a shareable URL for a recipe
    static func createShareURL(for recipe: Recipe) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/\(recipe.id.uuidString)"
        
        // Add recipe data as query parameters
        components.queryItems = [
            URLQueryItem(name: "name", value: recipe.name),
            URLQueryItem(name: "description", value: recipe.recipeDescription),
            URLQueryItem(name: "time", value: String(recipe.cookingTimeMinutes)),
            URLQueryItem(name: "difficulty", value: recipe.difficulty.rawValue),
            URLQueryItem(name: "notes", value: recipe.notes)
        ]
        
        // Add encoded ingredients
        let ingredientsData = recipe.ingredients.map { ingredient in
            [
                "name": ingredient.name,
                "amount": String(ingredient.amount),
                "unit": ingredient.unit,
                "notes": ingredient.notes ?? ""
            ]
        }
        if let ingredientsJSON = try? JSONEncoder().encode(ingredientsData),
           let ingredientsString = String(data: ingredientsJSON, encoding: .utf8) {
            components.queryItems?.append(URLQueryItem(name: "ingredients", value: ingredientsString))
        }
        
        // Add encoded steps
        let stepsData = recipe.steps.map { step in
            [
                "orderIndex": String(step.orderIndex),
                "description": step.stepDescription,
                "duration": step.durationMinutes.map(String.init) ?? "",
                "notes": step.notes ?? ""
            ]
        }
        if let stepsJSON = try? JSONEncoder().encode(stepsData),
           let stepsString = String(data: stepsJSON, encoding: .utf8) {
            components.queryItems?.append(URLQueryItem(name: "steps", value: stepsString))
        }
        
        return components.url
    }
    
    // Parse a shared URL back into a recipe
    static func parseShareURL(_ url: URL) -> Recipe? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.host == host,
              let queryItems = components.queryItems else {
            return nil
        }
        
        // Helper function to get query values
        func getValue(for name: String) -> String {
            queryItems.first(where: { $0.name == name })?.value ?? ""
        }
        
        // Parse basic recipe data
        let name = getValue(for: "name")
        let description = getValue(for: "description")
        let time = Int(getValue(for: "time")) ?? 0
        let difficulty = DifficultyLevel(rawValue: getValue(for: "difficulty").lowercased()) ?? .medium
        let notes = getValue(for: "notes")
        
        // Parse ingredients
        var ingredients: [Ingredient] = []
        if let ingredientsString = getValue(for: "ingredients").removingPercentEncoding,
           let ingredientsData = ingredientsString.data(using: .utf8),
           let ingredientsJSON = try? JSONDecoder().decode([[String: String]].self, from: ingredientsData) {
            ingredients = ingredientsJSON.map { data in
                Ingredient(
                    name: data["name"] ?? "",
                    amount: Double(data["amount"] ?? "0") ?? 0,
                    unit: data["unit"] ?? "",
                    notes: data["notes"].flatMap { $0.isEmpty ? nil : $0 }
                )
            }
        }
        
        // Parse steps
        var steps: [CookingStep] = []
        if let stepsString = getValue(for: "steps").removingPercentEncoding,
           let stepsData = stepsString.data(using: .utf8),
           let stepsJSON = try? JSONDecoder().decode([[String: String]].self, from: stepsData) {
            steps = stepsJSON.map { data in
                CookingStep(
                    orderIndex: Int(data["orderIndex"] ?? "0") ?? 0,
                    stepDescription: data["description"] ?? "",
                    durationMinutes: Int(data["duration"] ?? ""),
                    notes: data["notes"].flatMap { $0.isEmpty ? nil : $0 }
                )
            }
        }
        
        return Recipe(
            name: name,
            recipeDescription: description,
            ingredients: ingredients,
            steps: steps,
            cookingTimeMinutes: time,
            difficulty: difficulty,
            notes: notes
        )
    }
}
