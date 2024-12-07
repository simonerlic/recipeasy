//
//  PrintableRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-26.
//

import SwiftUI

struct PrintableRecipeView: View {
    let recipe: Recipe
    
    private var sortedIngredients: [Ingredient] {
        recipe.ingredients.sorted { $0.id.uuidString < $1.id.uuidString }
    }
    
    private var sortedSteps: [CookingStep] {
        recipe.steps.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.largeTitle.bold())
                
                if !recipe.recipeDescription.isEmpty {
                    Text(recipe.recipeDescription)
                        .font(.body)
                }
                
                HStack(spacing: 16) {
                    Label("\(recipe.cookingTimeMinutes) min", systemImage: "clock")
                    Label(recipe.difficulty.rawValue, systemImage: "chart.bar")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            // Ingredients
            if !recipe.ingredients.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.title2.bold())
                    
                    ForEach(sortedIngredients) { ingredient in
                        HStack(spacing: 8) {
                            Text("•")
                            Text("\(formatAmount(ingredient.amount)) \(ingredient.unit) \(ingredient.name)")
                            if let notes = ingredient.notes, !notes.isEmpty {
                                Text("(\(notes))")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Steps
            if !recipe.steps.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.title2.bold())
                    
                    ForEach(sortedSteps) { step in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(step.orderIndex + 1). \(step.stepDescription)")
                            
                            if let duration = step.durationMinutes {
                                Text("Duration: \(duration) min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let notes = step.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
            }
            
            // Notes
            if !recipe.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.title2.bold())
                    Text(recipe.notes)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func formatAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
            .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }
}
