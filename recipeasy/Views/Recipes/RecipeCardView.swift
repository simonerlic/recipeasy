////  RecipeCard.swift//  recipeasy////  Created by Simon Erlic on 2024-11-17.//import SwiftUIimport SwiftDatastruct RecipeCard: View {    @Environment(\.modelContext) private var modelContext    @Bindable var recipe: Recipe    @State private var showingCategorySheet = false    @State private var showingDeleteConfirmation = false        var body: some View {        VStack(alignment: .leading, spacing: 0) {            ZStack(alignment: .top) {                if let imageData = recipe.imageData,                   let uiImage = UIImage(data: imageData) {                    Image(uiImage: uiImage)                        .resizable()                        .scaledToFill()                        .frame(height: 150)                        .clipped()                }            }            .frame(maxWidth: .infinity)            .clipShape(Rectangle())                        VStack(alignment: .leading, spacing: 12) {                VStack(alignment: .leading, spacing: 8) {                    Text(recipe.name)                        .font(.title3)                        .bold()                        .foregroundStyle(.primary)                }                                if !recipe.recipeDescription.isEmpty {                    Text(recipe.recipeDescription)                        .font(.subheadline)                        .lineLimit(2)                        .foregroundStyle(.secondary)                }                                HStack {                    TimeChip(minutes: recipe.cookingTimeMinutes)                    DifficultyChip(recipe: recipe)                    Spacer()                }            }            .padding()        }        .background(Color(uiColor: .secondarySystemGroupedBackground))        .clipShape(RoundedRectangle(cornerRadius: 12))        .contentShape(Rectangle())        .contextMenu {            Button {                showingCategorySheet = true            } label: {                Label("Manage Categories", systemImage: "folder")            }                        Button(role: .destructive) {                showingDeleteConfirmation = true            } label: {                Label("Delete", systemImage: "trash")            }        }        .sheet(isPresented: $showingCategorySheet) {            CategorySelectionSheet(recipe: recipe)        }        .alert("Delete Recipe?", isPresented: $showingDeleteConfirmation) {            Button("Cancel", role: .cancel) { }            Button("Delete", role: .destructive) {                deleteRecipe()            }        } message: {            Text("Are you sure you want to delete this recipe? This action cannot be undone.")        }    }        private func deleteRecipe() {        recipe.ingredients.forEach { modelContext.delete($0) }        recipe.steps.forEach { modelContext.delete($0) }        modelContext.delete(recipe)    }        private var difficultyColor: Color {        switch recipe.difficulty {        case .easy:            return .green        case .medium:            return .orange        case .hard:            return .red        }    }}