//
//  RecipeDetailView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RecipeDescriptionSection(description: recipe.recipeDescription)
                RecipeIngredientsSection(ingredients: recipe.ingredients)
                RecipeStepsSection(steps: recipe.steps)
                if !recipe.notes.isEmpty {
                    RecipeNotesSection(notes: recipe.notes)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeDescriptionSection: View {
    let description: String
    
    var body: some View {
        if !description.isEmpty {
            Text(description)
                .padding(.bottom)
        }
    }
}

struct RecipeIngredientsSection: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)
            
            ForEach(ingredients) { ingredient in
                IngredientRow(ingredient: ingredient)
            }
        }
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        Text("\(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
    }
}

struct RecipeStepsSection: View {
    let steps: [CookingStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Steps")
                .font(.headline)
            
            ForEach(steps) { step in
                StepRow(step: step)
            }
        }
    }
}

struct StepRow: View {
    let step: CookingStep
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(step.orderIndex + 1). \(step.stepDescription)")
            
            if let duration = step.durationMinutes {
                Text("Duration: \(duration) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 4)
    }
}

struct RecipeNotesSection: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            Text(notes)
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
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
