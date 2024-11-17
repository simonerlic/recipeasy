//
//  RecipeRowView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
            Text("\(recipe.cookingTimeMinutes) min • \(recipe.difficulty.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        RecipeRowView(recipe: Recipe(
            name: "Test Recipe",
            recipeDescription: "A test recipe description",
            ingredients: [
                Ingredient(name: "Flour", amount: 2, unit: "cups"),
                Ingredient(name: "Sugar", amount: 1, unit: "cup")
            ],
            steps: [
                CookingStep(orderIndex: 0, stepDescription: "Mix ingredients", durationMinutes: 5),
                CookingStep(orderIndex: 1, stepDescription: "Bake", durationMinutes: 30)
            ],
            notes: "Test notes"
        ))
    }
}
