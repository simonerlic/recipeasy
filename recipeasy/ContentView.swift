// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: \Recipe.dateModified,
        order: .reverse,
        animation: .default
    ) private var recipes: [Recipe]
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeRowView(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddRecipe = true }) {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a recipe")
        }
        .sheet(isPresented: $showingAddRecipe) {
            NavigationStack {
                AddRecipeView()
            }
            .presentationDragIndicator(.visible)
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let recipe = recipes[index]
                // Delete related entities first
                recipe.ingredients.forEach { modelContext.delete($0) }
                recipe.steps.forEach { modelContext.delete($0) }
                modelContext.delete(recipe)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
