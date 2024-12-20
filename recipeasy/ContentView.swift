//
//
//  ContentView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//


import SwiftUI
import SwiftData
import WhatsNewKit

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
    @EnvironmentObject private var deepLinkHandler: DeepLinkHandler
    @State private var navigationPath = NavigationPath()

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
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical) {
                LazyVStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: recipe.id) {
                            RecipeCard(recipe: recipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("My Recipes")
            .navigationDestination(for: UUID.self) { recipeId in
                if let recipe = recipes.first(where: { recipe in recipe.id == recipeId }) {
                    RecipeDetailView(recipe: recipe)
                }
            }
            .onChange(of: deepLinkHandler.selectedRecipeId) { _, newValue in
                if let recipeId = newValue {
                    navigationPath.append(recipeId)
                    deepLinkHandler.selectedRecipeId = nil
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
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
                
            }
            .sheet(isPresented: $showingImportModal) {
                NavigationStack {
                    ImportRecipeView()
                        .presentationDetents([.large])
                }
            }
            .whatsNewSheet()
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let recipe = recipes[index]
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
        .environmentObject(DeepLinkHandler())
}
