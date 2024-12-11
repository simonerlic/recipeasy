//
//  recipeasyApp.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import SwiftUI
import SwiftData
import WhatsNewKit

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
        
        Task {
            await SubscriptionService.shared.updateSubscriptionStatus()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .environmentObject(deepLinkHandler)
                .environment(
                    \.whatsNew,
                     .init(
                        versionStore: UserDefaultsWhatsNewVersionStore(),
                        defaultLayout: WhatsNew.Layout(
                            featureListSpacing: 45
                        ),
                        whatsNewCollection: self
                        
                    )
                )
        }
    }
}

extension recipeasyApp: WhatsNewCollectionProvider {
    
    /// A WhatsNewCollection
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "1.1.0",
            title: .init(
                text: .init(
                    "What's New in\n"                    + AttributedString(
                        "Recipeasy",
                        attributes: .foregroundColor(.cyan)
                    )
                )
            ),
            features: [
                .init(
                    image: .init(
                        systemName: "clock.circle",
                        foregroundColor: .cyan
                    ),
                    title: "Hourly Homescreen Widgets",
                    subtitle: .init(
                        try! AttributedString(
                            markdown: "See your favourite recipes on your device's home screen with widgets!"
                        )
                    )
                ),
                .init(
                    image: .init(
                        systemName: "printer.fill",
                        foregroundColor: .cyan
                    ),
                    title: "Recipe Printouts",
                    subtitle: "Share your favourite recipes with friends and family via printable PDFs."
                ),
                .init(
                    image: .init(
                        systemName: "wand.and.stars",
                        foregroundColor: .cyan
                    ),
                    title: "Overhauled Recipe Generation",
                    subtitle: "Streamlined recipe generation prompts to ensure a more consistent experience."
                )
            ],
            primaryAction: .init(
                hapticFeedback: {
                    #if os(iOS)
                    .notification(.success)
                    #else
                    nil
                    #endif
                }()
            )
        )
    }
    
}

private extension AttributeContainer {
    
    /// A AttributeContainer with a given foreground color
    /// - Parameter color: The foreground color
    static func foregroundColor(
        _ color: Color
    ) -> Self {
        var container = Self()
        container.foregroundColor = color
        return container
    }
    
}

class DeepLinkHandler: ObservableObject {
    @Published var selectedRecipeId: UUID?
}
