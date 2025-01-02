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
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @State private var selectedCategory: Category?
    @State private var showingSettings = false
    @State private var showingCategories = false
    @State private var addRecipeSheet: AddRecipeSheet?
    @State private var showingImportModal = false
    @StateObject private var subscriptionService = SubscriptionService.shared
    @EnvironmentObject private var deepLinkHandler: DeepLinkHandler
    @State private var navigationPath = NavigationPath()
    
    // Dynamic recipes query based on selected category
    var filteredRecipes: [Recipe] {
        if let category = selectedCategory {
            return category.recipes.sorted { $0.dateModified > $1.dateModified }
        } else {
            // When no category is selected, fetch all recipes
            let descriptor = FetchDescriptor<Recipe>(
                sortBy: [SortDescriptor(\.dateModified, order: .reverse)]
            )
            return (try? modelContext.fetch(descriptor)) ?? []
        }
    }

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
                VStack(spacing: 16) {
                    // Category picker
                    if !categories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                categoryButton(nil)
                                ForEach(categories) { category in
                                    categoryButton(category)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Recipes
                    LazyVStack(spacing: 16) {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(value: recipe.id) {
                                RecipeCard(recipe: recipe)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Recipes")
            .navigationDestination(for: UUID.self) { recipeId in
                if let recipe = filteredRecipes.first(where: { recipe in recipe.id == recipeId }) {
                    RecipeDetailView(recipe: recipe)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { showingSettings = true }) {
                            Label("Settings", systemImage: "gear")
                        }
                        Button(action: { showingCategories = true }) {
                            Label("Manage Categories", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
            .sheet(isPresented: $showingCategories) {
                NavigationStack {
                    CategoryManagementView()
                }
            }
            .sheet(isPresented: $showingImportModal) {
                NavigationStack {
                    ImportRecipeView()
                        .presentationDetents([.large])
                }
            }
        }
    }
    
    private func categoryButton(_ category: Category?) -> some View {
        Button(action: { selectedCategory = category }) {
            Text(category?.name ?? "All Recipes")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedCategory?.id == category?.id ? Color.blue : Color(.secondarySystemBackground))
                )
                .foregroundStyle(selectedCategory?.id == category?.id ? .white : .primary)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
        .environmentObject(DeepLinkHandler())
}
