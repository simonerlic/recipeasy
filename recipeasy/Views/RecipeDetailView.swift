//
//  RecipeDetailView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI

struct TimeChip: View {
    let minutes: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.caption)
            Text(formatDuration(minutes: minutes))
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private func formatDuration(minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }
}

struct DifficultyChip: View {
    let recipe: Recipe
    
    var body: some View {
        Label(recipe.difficulty.rawValue, systemImage: "chart.bar.fill")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.15))
            .foregroundColor(difficultyColor)
            .clipShape(Capsule())
    }
    
    private var difficultyColor: Color {
        switch recipe.difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var recipe: Recipe
    @State private var completedSteps: Set<Int> = []
    @State private var showingEditSheet = false
    
    @State private var isShowingShareSheet = false
    @State private var shareItems: [Any] = []
    
    private var uniqueIngredients: [Ingredient] {
        Array(Set(recipe.ingredients))
    }
    
    private var uniqueSteps: [CookingStep] {
        Array(Set(recipe.steps))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                HStack {
                    TimeChip(minutes: recipe.cookingTimeMinutes)
                        .padding(.top, -8)
                    DifficultyChip(recipe: recipe)
                        .padding(.top, -8)
                }

                if !recipe.recipeDescription.isEmpty {
                    Text(recipe.recipeDescription)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !recipe.ingredients.isEmpty {
                    SectionHeader(title: "Ingredients")
                    IngredientsView(ingredients: uniqueIngredients)
                }
                
                if !recipe.steps.isEmpty {
                    SectionHeader(title: "Steps")
                    StepsView(steps: uniqueSteps, completedSteps: $completedSteps)
                }
                
                CookingHistoryView(recipe: recipe)
                
                if !recipe.notes.isEmpty {
                    SectionHeader(title: "Notes")
                        Text(recipe.notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareRecipe) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditRecipeView(recipe: recipe, onDelete: {
                    dismiss()  // This will dismiss the RecipeDetailView
                })
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ShareView(recipe: recipe)
                .presentationDragIndicator(.visible)
        }
    }
}

extension RecipeDetailView {
    private func shareRecipe() {
        if let url = RecipeShareManager.createShareURL(for: recipe) {
            let shareText = """
            Check out this recipe for \(recipe.name)!
            Open in Recipeasy: \(url.absoluteString)
            """
            isShowingShareSheet = true
            shareItems = [shareText]
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3 .bold())
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

struct CardView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(
            color: colorScheme == .dark
                ? .black.opacity(0.3)
                : .black.opacity(0.1),
            radius: colorScheme == .dark ? 8 : 4,
            x: 0,
            y: colorScheme == .dark ? 4 : 2
        )
    }
}

struct IngredientsView: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Use ingredient.id.uuidString to ensure truly unique identifiers
            ForEach(ingredients.sorted { $0.id.uuidString < $1.id.uuidString }, id: \.id.uuidString) { ingredient in
                HStack(alignment: .top, spacing: 12) {
                    Text("•")
                    VStack(alignment: .leading) {
                        Text("\(ingredient.name)")
                        Text("\(formatAmount(ingredient.amount)) \(ingredient.unit)")
                            .font(.footnote)
                        
                        Spacer()
                        
                        // check if notes is present or nonempty
                        if let notes = ingredient.notes {
                            if notes.isEmpty {
                                EmptyView()
                            } else {
                                Text("\(notes)")
                                    .foregroundStyle(.secondary)
                                    .font(.callout)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func formatAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
            .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }
}

struct StepsView: View {
    let steps: [CookingStep]
    @Binding var completedSteps: Set<Int>
    
    var body: some View {
        VStack(spacing: 12) {
            // Sort by orderIndex first, then use id.uuidString as the unique identifier
            ForEach(steps.sorted { $0.orderIndex < $1.orderIndex }, id: \.id.uuidString) { step in
                CardView {
                    StepItemView(
                        step: step,
                        isCompleted: completedSteps.contains(step.orderIndex)
                    ) {
                        if completedSteps.contains(step.orderIndex) {
                            completedSteps.remove(step.orderIndex)
                        } else {
                            completedSteps.insert(step.orderIndex)
                        }
                    }
                }
            }
        }
    }
}

struct StepItemView: View {
    let step: CookingStep
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {  // Remove spacing here
            if let imageData = step.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            }
            
            Button(action: onToggle) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isCompleted ? .green : .secondary)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(step.stepDescription)")
                                .strikethrough(isCompleted)
                                .foregroundStyle(isCompleted ? .secondary : .primary)
                            
                            if let duration = step.durationMinutes {
                                Label {
                                    Text(formatDuration(minutes: duration))
                                } icon: {
                                    Image(systemName: "clock")
                                }
                                .foregroundStyle(.secondary)
                                .font(.callout)
                            }
                            
                            if let notes = step.notes {
                                Text(notes)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private func formatDuration(minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            name: "Test Recipe",
            recipeDescription: "A test recipe description that's a bit longer to show how it wraps and fills the card nicely.",
            ingredients: [
                Ingredient(name: "Flour", amount: 2, unit: "cups", notes: "All-purpose"),
                Ingredient(name: "Sugar", amount: 1, unit: "cup"),
                Ingredient(name: "Butter", amount: 0.5, unit: "cup", notes: "Softened")
            ],
            steps: [
                CookingStep(orderIndex: 0, stepDescription: "Mix dry ingredients", durationMinutes: 5, notes: "Whisk to combine"),
                CookingStep(orderIndex: 1, stepDescription: "Cream butter and sugar", durationMinutes: 10),
                CookingStep(orderIndex: 2, stepDescription: "Bake until golden brown", durationMinutes: 30, notes: "Rotate halfway through")
            ],
            cookingTimeMinutes: 45,
            notes: "This is a test note that provides additional context and tips for the recipe."
        ))
    }
    .preferredColorScheme(.light)
}
