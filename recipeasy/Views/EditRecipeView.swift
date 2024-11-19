//
//  EditRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-17.
//


import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var recipe: Recipe
    
    let onDelete: () -> Void
    
    @State private var name: String
    @State private var recipeDescription: String
    @State private var cookingTimeMinutes: Int
    @State private var difficulty: DifficultyLevel
    @State private var notes: String
    @State private var imageData: Data?
    
    // State for step input
    @State private var showingAddStep = false
    @State private var currentStepDescription = ""
    @State private var currentStepDuration = 15
    @State private var currentStepNotes = ""
    
    // State for ingredient input
    @State private var showingAddIngredient = false
    @State private var currentIngredientName = ""
    @State private var currentIngredientAmount = ""
    @State private var currentIngredientUnit = ""
    @State private var currentIngredientNotes = ""
    
    @State private var showingDeleteConfirmation = false
    
    init(recipe: Recipe, onDelete: @escaping () -> Void) {
        self.recipe = recipe
        self.onDelete = onDelete
        _name = State(initialValue: recipe.name)
        _recipeDescription = State(initialValue: recipe.recipeDescription)
        _cookingTimeMinutes = State(initialValue: recipe.cookingTimeMinutes)
        _difficulty = State(initialValue: recipe.difficulty)
        _notes = State(initialValue: recipe.notes)
        _imageData = State(initialValue: recipe.imageData)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Recipe Name", text: $name)
                TextField("Description", text: $recipeDescription, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section(header: Text("Image")) {
                ImagePicker(imageData: $imageData, title: "Recipe Image")
            }
            
            Section(header: Text("Details")) {
                TimeInputView(
                    minutes: $cookingTimeMinutes,
                    range: 1...480,
                    stepSize: 5,
                    label: "Cooking Time"
                )
                
                Picker("Difficulty", selection: $difficulty) {
                    Text("Easy").tag(DifficultyLevel.easy)
                    Text("Medium").tag(DifficultyLevel.medium)
                    Text("Hard").tag(DifficultyLevel.hard)
                }
            }
            
            Section(header: Text("Ingredients")) {
                ForEach(recipe.ingredients) { ingredient in
                    IngredientRowEdit(ingredient: ingredient)
                }
                .onDelete { indices in
                    for index in indices {
                        let ingredient = recipe.ingredients[index]
                        recipe.ingredients.remove(at: index)
                        modelContext.delete(ingredient)
                    }
                }
                
                Button(action: { showingAddIngredient = true }) {
                    Label("Add Ingredient", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Steps")) {
                ForEach(recipe.steps.sorted { $0.orderIndex < $1.orderIndex }) { step in
                    StepRowEdit(step: step)
                }
                .onMove { indices, newOffset in
                    recipe.steps.move(fromOffsets: indices, toOffset: newOffset)
                    // Update order indices
                    for (index, step) in recipe.steps.enumerated() {
                        step.orderIndex = index
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        let step = recipe.steps[index]
                        recipe.steps.remove(at: index)
                        modelContext.delete(step)
                    }
                }
                
                Button(action: { showingAddStep = true }) {
                    Label("Add Step", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Notes")) {
                TextField("Recipe Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            
            if !name.isEmpty {
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true  // Show confirmation instead of direct deletion
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Recipe")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Edit Recipe")
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
        .sheet(isPresented: $showingAddStep) {
            NavigationStack {
                AddStepView(
                    stepDescription: $currentStepDescription,
                    duration: $currentStepDuration,
                    notes: $currentStepNotes,
                    onSave: {
                        let newStep = CookingStep(
                            orderIndex: recipe.steps.count,
                            stepDescription: currentStepDescription,
                            durationMinutes: currentStepDuration,
                            notes: currentStepNotes.isEmpty ? nil : currentStepNotes
                        )
                        newStep.recipe = recipe
                        modelContext.insert(newStep)
                        recipe.steps.append(newStep)
                        
                        // Reset input
                        currentStepDescription = ""
                        currentStepDuration = 15
                        currentStepNotes = ""
                    }
                )
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddIngredient) {
            NavigationStack {
                AddIngredientView(
                    name: $currentIngredientName,
                    amount: $currentIngredientAmount,
                    unit: $currentIngredientUnit,
                    notes: $currentIngredientNotes,
                    onSave: {
                        guard let amount = Double(currentIngredientAmount) else { return }
                        
                        let newIngredient = Ingredient(
                            name: currentIngredientName,
                            amount: amount,
                            unit: currentIngredientUnit,
                            notes: currentIngredientNotes.isEmpty ? nil : currentIngredientNotes
                        )
                        newIngredient.recipe = recipe
                        modelContext.insert(newIngredient)
                        recipe.ingredients.append(newIngredient)
                        
                        // Reset input
                        currentIngredientName = ""
                        currentIngredientAmount = ""
                        currentIngredientUnit = ""
                        currentIngredientNotes = ""
                    }
                )
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Delete Recipe?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRecipe()
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
    }
    
    private func saveRecipe() {
        recipe.name = name
        recipe.recipeDescription = recipeDescription
        recipe.cookingTimeMinutes = cookingTimeMinutes
        recipe.difficulty = difficulty
        recipe.notes = notes
        recipe.imageData = imageData
        recipe.dateModified = Date()
        dismiss()
    }
    
    private func deleteRecipe() {
        // Delete related entities first
        recipe.ingredients.forEach { modelContext.delete($0) }
        recipe.steps.forEach { modelContext.delete($0) }
        // Then delete the recipe
        modelContext.delete(recipe)
        dismiss() // Dismiss the edit view
        onDelete() // Dismiss the detail view
    }
}

#Preview {
    NavigationStack {
        EditRecipeView(
            recipe: Recipe(
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
            ),
            onDelete: {}
        )
    }
}
