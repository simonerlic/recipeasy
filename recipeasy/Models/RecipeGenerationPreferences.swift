//
//  CookingTimePreference.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-12-12.
//


import Foundation

enum CookingTimePreference: String, Codable, CaseIterable {
    case any = "Any Time"
    case quick = "< 30 mins"
    case medium = "30-60 mins"
    case long = "60+ mins"
}

enum CuisinePreference: String, Codable, CaseIterable {
    case any = "Any Cuisine"
    case italian = "Italian"
    case asian = "Asian"
    case mexican = "Mexican"
    case mediterranean = "Mediterranean"
}

struct DietaryRestriction: Identifiable, Hashable, Codable {
    let id: String
    let label: String
    
    static let allCases: [DietaryRestriction] = [
        DietaryRestriction(id: "vegetarian", label: "Vegetarian"),
        DietaryRestriction(id: "vegan", label: "Vegan"),
        DietaryRestriction(id: "glutenFree", label: "Gluten-Free"),
        DietaryRestriction(id: "dairyFree", label: "Dairy-Free")
    ]
}

struct QuickSuggestion: Identifiable {
    let id: UUID
    let emoji: String
    let text: String
    let preferences: RecipePreferences
    
    init(emoji: String, text: String, preferences: RecipePreferences) {
        self.id = UUID()
        self.emoji = emoji
        self.text = text
        self.preferences = preferences
    }
}

// MARK: - Equatable
extension QuickSuggestion: Equatable {
    static func == (lhs: QuickSuggestion, rhs: QuickSuggestion) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension QuickSuggestion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Static Suggestions
extension QuickSuggestion {
    private static let allSuggestions: [QuickSuggestion] = [
        // Quick meals
        QuickSuggestion(
            emoji: "🍝",
            text: "Quick weeknight pasta dish",
            preferences: RecipePreferences(
                cookingTime: .quick,
                cuisine: .italian
            )
        ),
        QuickSuggestion(
            emoji: "🥘",
            text: "One-pot family dinner",
            preferences: RecipePreferences(
                cookingTime: .medium
            )
        ),
        QuickSuggestion(
            emoji: "🥪",
            text: "Gourmet sandwich",
            preferences: RecipePreferences(
                cookingTime: .quick
            )
        ),
        
        // Healthy options
        QuickSuggestion(
            emoji: "🥗",
            text: "Healthy meal prep recipe",
            preferences: RecipePreferences(
                dietaryRestrictions: ["glutenFree"]
            )
        ),
        QuickSuggestion(
            emoji: "🥬",
            text: "Vegetarian protein bowl",
            preferences: RecipePreferences(
                dietaryRestrictions: ["vegetarian"]
            )
        ),
        QuickSuggestion(
            emoji: "🍜",
            text: "Low-carb Asian stir-fry",
            preferences: RecipePreferences(
                cookingTime: .quick,
                cuisine: .asian
            )
        ),
        
        // International cuisine
        QuickSuggestion(
            emoji: "🌮",
            text: "Authentic Mexican tacos",
            preferences: RecipePreferences(
                cuisine: .mexican
            )
        ),
        QuickSuggestion(
            emoji: "🍛",
            text: "Traditional curry recipe",
            preferences: RecipePreferences(
                cookingTime: .medium,
                cuisine: .asian
            )
        ),
        QuickSuggestion(
            emoji: "🫔",
            text: "Mediterranean feast",
            preferences: RecipePreferences(
                cuisine: .mediterranean
            )
        ),
        
        // Special occasions
        QuickSuggestion(
            emoji: "🍖",
            text: "Weekend roast dinner",
            preferences: RecipePreferences(
                cookingTime: .long
            )
        ),
        QuickSuggestion(
            emoji: "🥘",
            text: "Date night risotto",
            preferences: RecipePreferences(
                cookingTime: .medium,
                cuisine: .italian
            )
        ),
        QuickSuggestion(
            emoji: "🥙",
            text: "Party appetizers",
            preferences: RecipePreferences(
                cookingTime: .medium
            )
        ),
        
        // Easy
        QuickSuggestion(
            emoji: "🥞",
            text: "Banana Buttermilk Pancakes",
            preferences: RecipePreferences(
            )
        )
    ]
    
    static func getRandomSuggestions(count: Int = 3) -> [QuickSuggestion] {
        Array(allSuggestions.shuffled().prefix(count))
    }
}

struct RecipePreferences: Codable, Hashable {
    var dietaryRestrictions: Set<String>
    var cookingTime: CookingTimePreference
    var cuisine: CuisinePreference
    
    init(
        dietaryRestrictions: Set<String> = [],
        cookingTime: CookingTimePreference = .any,
        cuisine: CuisinePreference = .any
    ) {
        self.dietaryRestrictions = dietaryRestrictions
        self.cookingTime = cookingTime
        self.cuisine = cuisine
    }
    
    func buildPromptPrefix() -> String {
        var components: [String] = []
        
        // Add dietary restrictions
        if !dietaryRestrictions.isEmpty {
            let restrictions = dietaryRestrictions.map { $0.capitalized }.joined(separator: ", ")
            components.append("Must be \(restrictions)")
        }
        
        // Add cooking time preference
        if cookingTime != .any {
            switch cookingTime {
            case .quick:
                components.append("Should take less than 30 minutes to prepare")
            case .medium:
                components.append("Should take between 30-60 minutes to prepare")
            case .long:
                components.append("Can take over an hour to prepare")
            default:
                break
            }
        }
        
        // Add cuisine preference
        if cuisine != .any {
            components.append("Should be \(cuisine.rawValue) cuisine")
        }
        
        return components.isEmpty ? "" : components.joined(separator: ". ") + ". "
    }
}
