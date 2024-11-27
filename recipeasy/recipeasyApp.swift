//
//  recipeasyApp.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

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
                CookingStep.self,
                RecipeAttempt.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .identifier("group.dev.serlic.recipeasy")
            )
            
            self.sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        Task {
            await SubscriptionService.shared.updateSubscriptionStatus()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onOpenURL { url in
                    if url.scheme == "recipeasy" && url.host == "recipe",
                       let recipeId = UUID(uuidString: url.lastPathComponent) {
                    }
                }
        }
    }
}
