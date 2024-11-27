//
//  Provider.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-26.
//


// RandomRecipeWidget.swift

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: @preconcurrency TimelineProvider {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([Recipe.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .identifier("group.dev.serlic.recipeasy")
            )
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    func placeholder(in context: Context) -> RandomRecipeEntry {
        RandomRecipeEntry(date: Date(), recipe: Recipe(
            name: "Loading Recipe...",
            recipeDescription: "Your random recipe will appear here",
            cookingTimeMinutes: 30,
            difficulty: .medium
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (RandomRecipeEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        
        do {
            let descriptor = FetchDescriptor<Recipe>()
            let recipes = try modelContainer.mainContext.fetch(descriptor)
            
            if recipes.isEmpty {
                let entry = placeholder(in: context)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
                return
            }
            
            // Create a single entry with a random recipe
            let randomRecipe = recipes.randomElement()!
            let entry = RandomRecipeEntry(date: Date(), recipe: randomRecipe)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            
        } catch {
            print("Error fetching recipes: \(error)")
            let entry = placeholder(in: context)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct RandomRecipeEntry: TimelineEntry {
    let date: Date
    let recipe: Recipe
}

struct RandomRecipeWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallRecipeWidget(recipe: entry.recipe)
        case .systemMedium:
            MediumRecipeWidget(recipe: entry.recipe)
        default:
            SmallRecipeWidget(recipe: entry.recipe)
        }
    }
}

@main
struct RandomRecipeWidget: Widget {
    let kind: String = "RandomRecipeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                RandomRecipeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                RandomRecipeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Random Recipe")
        .description("Displays a random recipe from your collection.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    RandomRecipeWidget()
} timeline: {
    RandomRecipeEntry(
        date: .now,
        recipe: Recipe(
            name: "Preview Recipe",
            recipeDescription: "A sample recipe",
            cookingTimeMinutes: 30,
            difficulty: .medium
        )
    )
}
