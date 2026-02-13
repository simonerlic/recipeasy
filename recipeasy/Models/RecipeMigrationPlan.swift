//
//  RecipeMigrationPlan.swift
//  recipeasy
//
//  Handles schema migrations to preserve user data across app updates
//
//  NOTE: Currently not in use. SwiftData automatically handles migration from
//  the unversioned schema to RecipeSchemaV2 (version 1.0.0).
//
//  This file is kept for future migrations when we need to go from V2 to V3, etc.
//

import Foundation
import SwiftData

enum RecipeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [RecipeSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        // No migration stages needed yet
        // SwiftData handles unversioned → V2 automatically
        []
    }

    // For future migrations, add custom migration stages here
    // Example when we create V3:
    //
    // enum RecipeMigrationPlan: SchemaMigrationPlan {
    //     static var schemas: [any VersionedSchema.Type] {
    //         [RecipeSchemaV2.self, RecipeSchemaV3.self]
    //     }
    //
    //     static var stages: [MigrationStage] {
    //         [migrateV2toV3]
    //     }
    //
    //     static let migrateV2toV3 = MigrationStage.lightweight(
    //         fromVersion: RecipeSchemaV2.self,
    //         toVersion: RecipeSchemaV3.self
    //     )
    // }
}
