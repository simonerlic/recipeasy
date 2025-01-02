//
//  CategorySelectionSheet.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-02.
//

import SwiftUI
import SwiftData

struct CategorySelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Bindable var recipe: Recipe
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button {
                        toggleCategory(category)
                    } label: {
                        HStack {
                            Text(category.name)
                            Spacer()
                            if recipe.categories.contains(where: { $0.id == category.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleCategory(_ category: Category) {
        if recipe.categories.contains(where: { $0.id == category.id }) {
            recipe.categories.removeAll { $0.id == category.id }
            category.recipes.removeAll { $0.id == recipe.id }
        } else {
            recipe.categories.append(category)
            category.recipes.append(recipe)
        }
    }
}
