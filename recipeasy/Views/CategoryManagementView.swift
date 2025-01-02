//
//  CategoryManagementView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-02.
//


import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    @State private var newCategoryName = ""
    @State private var showingAddCategory = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        List {
            ForEach(categories) { category in
                HStack {
                    Text(category.name)
                    Spacer()
                    Text("\(category.recipes.count) recipes")
                        .foregroundStyle(.secondary)
                }
            }
            .onMove { indices, newOffset in
                var updatedCategories = categories
                updatedCategories.move(fromOffsets: indices, toOffset: newOffset)
                
                // Update sort order
                for (index, category) in updatedCategories.enumerated() {
                    category.sortOrder = index
                }
                
                // Save changes
                try? modelContext.save()
            }
            .onDelete { indices in
                for index in indices {
                    modelContext.delete(categories[index])
                }
                // Save changes after deletion
                try? modelContext.save()
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Text("Done")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddCategory) {
            NavigationStack {
                Form {
                    TextField("Category Name", text: $newCategoryName)
                }
                .navigationTitle("New Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddCategory = false
                            newCategoryName = ""
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            let category = Category(
                                name: newCategoryName,
                                sortOrder: categories.count
                            )
                            modelContext.insert(category)
                            // Save changes after adding
                            try? modelContext.save()
                            
                            showingAddCategory = false
                            newCategoryName = ""
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
            .presentationDetents([.height(200)])
        }
    }
}
