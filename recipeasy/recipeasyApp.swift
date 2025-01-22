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
                RecipeAttempt.self,
                Category.self
            ])
            
            // Use default URL in the app's Documents directory
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
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
                .onOpenURL { url in
                    guard url.scheme == "recipeasy" else {
                        return
                    }
                    
                    // Handle recipe deep links
                    if url.host == "recipe",
                       let recipeId = UUID(uuidString: url.lastPathComponent) {
                        deepLinkHandler.selectedRecipeId = recipeId
                    }
                    print("Handling URL: \(url)")
                    // Pass URL to handler for additional processing
                    deepLinkHandler.handleURL(url)
                }

        }
    }
}

// MARK: - App+WhatsNewCollectionProvider

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
        WhatsNew(
            version: "1.3.0",
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
                        systemName: "folder",
                        foregroundColor: .cyan
                    ),
                    title: "Recipe Collections",
                    subtitle: .init(
                        try! AttributedString(
                            markdown: "Organize your recipes in easy-to-sort collections"
                        )
                    )
                ),
                .init(
                    image: .init(
                        systemName: "magnifyingglass",
                        foregroundColor: .cyan
                    ),
                    title: "Recipe Searching",
                    subtitle: .init(
                        try! AttributedString(
                            markdown: "Search your recipes by title, description, or ingredients"
                        )
                    )
                ),
                .init(
                    image: .init(
                        systemName: "square.and.arrow.down",
                        foregroundColor: .cyan
                    ),
                    title: "Import from PDF",
                    subtitle: "Import recipes from PDFs directly into Recipeasy"
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
    @Published var showingImportURL: URL?
    @Published var showingImportModal = false
    
    func handleURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        switch components.host {
        case "import":
            print("importing!")
            if let urlString = components.queryItems?.first(where: { $0.name == "url" })?.value,
               let importURL = URL(string: urlString) {
                showingImportURL = importURL
                showingImportModal = true
            }
        default:
            break
        }
    }
}
