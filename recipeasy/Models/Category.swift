//
//  Category.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-02.
//

import SwiftData
import Foundation

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var dateCreated: Date
    var sortOrder: Int
    @Relationship(deleteRule: .nullify, inverse: \Recipe.categories) var recipes: [Recipe]
    
    init(
        id: UUID = UUID(),
        name: String = "",
        sortOrder: Int = 0,
        recipes: [Recipe] = []
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.recipes = recipes
        self.dateCreated = Date()
    }
    
    // Helper method to save context
    func save(context: ModelContext) throws {
        try context.save()
    }
}
