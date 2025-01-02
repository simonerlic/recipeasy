//
//  CategorySelectorView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-02.
//


import SwiftUI
import SwiftData

struct CategorySelectorView: View {
    @Binding var selectedCategory: Category?
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            Text("None")
                .tag(nil as Category?)
            ForEach(categories) { category in
                Text(category.name)
                    .tag(category as Category?)
            }
        }
    }
}