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
    @State private var searchText = ""
    
    // Dynamic recipes query based on selected category and search text
    var filteredRecipes: [Recipe] {
        let categoryFiltered: [Recipe]
        if let category = selectedCategory {
            categoryFiltered = category.recipes.sorted { $0.dateModified > $1.dateModified }
        } else {
            let descriptor = FetchDescriptor<Recipe>(
                sortBy: [SortDescriptor(\.dateModified, order: .reverse)]
            )
            categoryFiltered = (try? modelContext.fetch(descriptor)) ?? []
        }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.recipeDescription.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }

    enum AddRecipeSheet: Identifiable {
        case manual, ai, pdf
        
        var id: Int {
            switch self {
            case .manual: return 1
            case .ai: return 2
            case .pdf: return 3
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search recipes...", text: $searchText)
                            .textFieldStyle(.plain)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    
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
                        .padding(.top, 8)
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
                            Button(action: { addRecipeSheet = .pdf }) {
                                Label("PDF Document", systemImage: "doc.text")
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
                        case .pdf:
                            PDFImportView()
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
                    ImportRecipeView(initialURL: deepLinkHandler.showingImportURL)
                        .presentationDetents([.large])
                }
            }
            .onChange(of: deepLinkHandler.selectedRecipeId) { _, newValue in
                if let recipeId = newValue {
                    navigationPath.append(recipeId)
                    deepLinkHandler.selectedRecipeId = nil
                }
            }
            .onChange(of: deepLinkHandler.showingImportModal) { _, newValue in
                showingImportModal = newValue
            }
            .whatsNewSheet()
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
