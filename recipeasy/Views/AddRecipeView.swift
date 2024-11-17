//
//  AddRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var recipeDescription = ""
    @State private var cookingTimeMinutes = 30
    @State private var difficulty = DifficultyLevel.medium
    @State private var notes = ""
    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Recipe Name", text: $name)
                TextField("Description", text: $recipeDescription, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section(header: Text("Details")) {
                Stepper("Cooking Time: \(cookingTimeMinutes) min", value: $cookingTimeMinutes, in: 1...480)
                Picker("Difficulty", selection: $difficulty) {
                    Text("Easy").tag(DifficultyLevel.easy)
                    Text("Medium").tag(DifficultyLevel.medium)
                    Text("Hard").tag(DifficultyLevel.hard)
                }
            }
            
            Section(header: Text("Notes")) {
                TextField("Recipe Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle("New Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveRecipe()
                }
                .disabled(name.isEmpty)
            }
        }
    }
    
    private func saveRecipe() {
        let recipe = Recipe(
            name: name,
            recipeDescription: recipeDescription,
            cookingTimeMinutes: cookingTimeMinutes,
            difficulty: difficulty,
            notes: notes
        )
        modelContext.insert(recipe)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddRecipeView()
    }
}
