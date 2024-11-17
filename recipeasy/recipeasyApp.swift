//
//  recipeasyApp.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//


// recipeasyApp.swift
import SwiftUI
import SwiftData

@main
struct recipeasyApp: App {
    let sharedModelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Recipe.self,
                Ingredient.self,
                CookingStep.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            self.sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
