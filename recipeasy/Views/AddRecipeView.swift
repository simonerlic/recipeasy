//
//  AddRecipeView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI

struct TimeInputView: View {
    @Binding var minutes: Int
    let range: ClosedRange<Int>
    let stepSize: Int
    let label: String
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var timeText: String = ""
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            
            TextField("", text: $timeText)
                .focused($isTextFieldFocused)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 50)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    timeText = "\(minutes)"
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    if !newValue {  // When losing focus
                        validateAndUpdateTime()
                    }
                }
                .onChange(of: timeText) { _, newValue in
                    // Only allow numeric input
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        timeText = filtered
                    }
                }
                .onChange(of: minutes) { _, newValue in
                    if !isTextFieldFocused {
                        timeText = "\(newValue)"
                    }
                }
            
            Text("min")
                .foregroundStyle(.secondary)
        }
    }
    
    private func validateAndUpdateTime() {
        if let newValue = Int(timeText) {
            if newValue < range.lowerBound {
                minutes = range.lowerBound
            } else if newValue > range.upperBound {
                minutes = range.upperBound
            } else {
                minutes = newValue
            }
        }
        timeText = "\(minutes)"
    }
}

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var recipeDescription = ""
    @State private var cookingTimeMinutes = 30
    @State private var difficulty = DifficultyLevel.medium
    @State private var notes = ""
    @State private var steps: [CookingStep] = []
    @State private var ingredients: [Ingredient] = []
    
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
    
    // Temporary recipe for managing relationships
    @State private var temporaryRecipe: Recipe?
    
    @State private var imageData: Data?
    
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
                ForEach(ingredients) { ingredient in
                    IngredientRowEdit(ingredient: ingredient)
                }
                .onDelete { indices in
                    for index in indices {
                        let ingredient = ingredients[index]
                        ingredients.remove(at: index)
                        modelContext.delete(ingredient)
                    }
                }
                
                Button(action: { showingAddIngredient = true }) {
                    Label("Add Ingredient", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Steps")) {
                ForEach(steps) { step in
                    StepRowEdit(step: step)
                }
                .onMove { indices, newOffset in
                    steps.move(fromOffsets: indices, toOffset: newOffset)
                    // Update order indices
                    for (index, step) in steps.enumerated() {
                        step.orderIndex = index
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        let step = steps[index]
                        steps.remove(at: index)
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
        }
        .navigationTitle("New Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    // Clean up any temporary data
                    if let recipe = temporaryRecipe {
                        modelContext.delete(recipe)
                    }
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
        .onAppear {
            // Create a temporary recipe to manage relationships
            let recipe = Recipe(
                name: "Temporary",
                recipeDescription: "",
                ingredients: [],
                steps: [],
                cookingTimeMinutes: 30
            )
            modelContext.insert(recipe)
            temporaryRecipe = recipe
        }
        .sheet(isPresented: $showingAddStep) {
            NavigationStack {
                AddStepView(
                    stepDescription: $currentStepDescription,
                    duration: $currentStepDuration,
                    notes: $currentStepNotes,
                    onSave: {
                        guard let recipe = temporaryRecipe else { return }
                        
                        let newStep = CookingStep(
                            orderIndex: steps.count,
                            stepDescription: currentStepDescription,
                            durationMinutes: currentStepDuration,
                            notes: currentStepNotes.isEmpty ? nil : currentStepNotes,
                            imageData: imageData
                        )
                        newStep.recipe = recipe
                        modelContext.insert(newStep)
                        steps.append(newStep)
                        
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
                        guard let recipe = temporaryRecipe,
                              let amount = Double(currentIngredientAmount) else { return }
                        
                        let newIngredient = Ingredient(
                            name: currentIngredientName,
                            amount: amount,
                            unit: currentIngredientUnit,
                            notes: currentIngredientNotes.isEmpty ? nil : currentIngredientNotes
                        )
                        newIngredient.recipe = recipe
                        modelContext.insert(newIngredient)
                        ingredients.append(newIngredient)
                        
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
    }
    
    private func saveRecipe() {
        if let recipe = temporaryRecipe {
            recipe.name = name
            recipe.recipeDescription = recipeDescription
            recipe.cookingTimeMinutes = cookingTimeMinutes
            recipe.difficulty = difficulty
            recipe.notes = notes
            recipe.imageData = imageData
            dismiss()
        }
    }
}

struct IngredientRowEdit: View {
    let ingredient: Ingredient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("•")
                    .baselineOffset(2)
                
                Text("\(formatAmount(ingredient.amount)) \(ingredient.unit) \(ingredient.name)")
                
                if let notes = ingredient.notes {
                    Text("(\(notes))")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatAmount(_ value: Double) -> String {
        // If it's a whole number, show no decimals
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        
        // For decimals, show at most 2 significant figures
        return String(format: "%.2f", value)
            .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }
}

struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var amount: String
    @Binding var unit: String
    @Binding var notes: String
    let onSave: () -> Void
    
    private let commonUnits = ["g", "kg", "ml", "L", "cup", "tbsp", "tsp", "oz", "lb", "piece", "slice", ""]
    
    var isValidAmount: Bool {
        guard !amount.isEmpty else { return false }
        if let value = Double(amount) {
            return value > 0
        }
        return false
    }
    
    var body: some View {
        Form {
            TextField("Ingredient Name", text: $name)
            
            HStack {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { _, newValue in
                        // Only allow numeric input and single decimal point
                        let filtered = newValue.filter {
                            $0.isNumber || ($0 == "." && !amount.contains("."))
                        }
                        if filtered != newValue {
                            amount = filtered
                        }
                    }
                
                Picker("Unit", selection: $unit) {
                    ForEach(commonUnits, id: \.self) { unit in
                        Text(unit.isEmpty ? "none" : unit).tag(unit)
                    }
                }
            }
            
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(2...4)
        }
        .navigationTitle("Add Ingredient")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    onSave()
                    dismiss()
                }
                .disabled(name.isEmpty || !isValidAmount)
            }
        }
    }
}

struct StepRowEdit: View {
    let step: CookingStep
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(step.stepDescription)
            if let duration = step.durationMinutes {
                Text("Duration: \(duration) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notes = step.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AddStepView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stepDescription: String
    @Binding var duration: Int
    @Binding var notes: String
    
    @State private var imageData: Data?
    
    let onSave: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Image (Optional)")) {
                ImagePicker(imageData: $imageData, title: "Step Image")
            }
            
            Section(header: Text("Details")) {
                TextField("Step Description", text: $stepDescription, axis: .vertical)
                    .lineLimit(3...6)
                
                TimeInputView(
                    minutes: $duration,
                    range: 1...240,
                    stepSize: 5,
                    label: "Duration"
                )
                
                TextField("Step Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle("Add Step")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    onSave()
                    dismiss()
                }
                .disabled(stepDescription.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddRecipeView()
    }
}
