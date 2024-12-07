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
    @StateObject private var deepLinkHandler = DeepLinkHandler()
    
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
        
        UILabel.appearance().adjustsFontForContentSizeCategory = true
        
        Task {
            await SubscriptionService.shared.updateSubscriptionStatus()
        }
        
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   Font: \(name)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .environmentObject(deepLinkHandler)
                .onOpenURL { url in
                    guard url.scheme == "recipeasy",
                          url.host == "recipe",
                          let recipeId = UUID(uuidString: url.lastPathComponent) else {
                        return
                    }
                    deepLinkHandler.selectedRecipeId = recipeId
                }
        }
    }
}

class DeepLinkHandler: ObservableObject {
    @Published var selectedRecipeId: UUID?
}
