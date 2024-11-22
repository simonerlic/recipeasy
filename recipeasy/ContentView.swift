//
//
//  ContentView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: \Recipe.dateModified,
        order: .reverse,
        animation: .default
    ) private var recipes: [Recipe]
    @State private var showingSettings = false
    @State private var addRecipeSheet: AddRecipeSheet?
    @State private var showingImportModal = false
    @StateObject private var subscriptionService = SubscriptionService.shared

    enum AddRecipeSheet: Identifiable {
        case manual, ai
        
        var id: Int {
            switch self {
            case .manual: return 1
            case .ai: return 2
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            ScrollView(.vertical) {
                LazyVStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                            
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { addRecipeSheet = .manual }) {
                            Label("Manual Entry", systemImage: "square.and.pencil")
                        }
                        Button(action: { addRecipeSheet = .ai }) {
                            Label("AI Generator", systemImage: "wand.and.stars")
                        }
                        Menu {
                            Button(action: { showingImportModal = true }) {
                                Label("Recipe Website", systemImage: "link")
                            }
                        } label: {
                            Label("Import from...", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $addRecipeSheet) { sheet in
                NavigationStack {
                    switch sheet {
                    case .manual:
                        AddRecipeView()
                    case .ai:
                        GenerateRecipeView()
                    }
                }
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingImportModal) {
                if !subscriptionService.hasActiveSubscription {
                    ImportRecipeView()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                } else {
                    ImportRecipeView()
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
                
            }
        } detail: {
            Text("Click the '+' button to add a new recipe, or select an existing one from the list.")
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
