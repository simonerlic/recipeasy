//
//  RecipeTheme.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-12-09.
//


import SwiftUI

// MARK: - Color Extension
extension Color {
    static let recipePrimary = Color("Text")
    static let recipeSecondary = Color("SecondaryText")
    static let recipeBackground = Color("Background")
    static let recipeSecondaryBackground = Color("SecondaryBackground")
    static let recipeAccent = Color("Accent")
}

// MARK: - Theme Environment Key
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = .standard
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - Theme
struct Theme {
    let textColor: Color
    let secondaryTextColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color
    let accentColor: Color
    
    static let standard = Theme(
        textColor: .recipePrimary,
        secondaryTextColor: .recipeSecondary,
        backgroundColor: .recipeBackground,
        secondaryBackgroundColor: .recipeSecondaryBackground,
        accentColor: .recipeAccent
    )
}

// MARK: - View Extension
extension View {
    func withRecipeTheme() -> some View {
        self
            .foregroundStyle(Color.recipePrimary)
            .tint(Color.recipeAccent)
            .background(Color.recipeBackground)
    }
}

// MARK: - Custom Theme Modifiers
struct RecipeTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.recipePrimary)
    }
}

struct RecipeSecondaryTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.recipeSecondary)
    }
}

struct RecipeBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.recipeBackground)
    }
}

struct RecipeSecondaryBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.recipeSecondaryBackground)
    }
}

// MARK: - View Extension for Modifiers
extension View {
    func recipeText() -> some View {
        modifier(RecipeTextModifier())
    }
    
    func recipeSecondaryText() -> some View {
        modifier(RecipeSecondaryTextModifier())
    }
    
    func recipeBackground() -> some View {
        modifier(RecipeBackgroundModifier())
    }
    
    func recipeSecondaryBackground() -> some View {
        modifier(RecipeSecondaryBackgroundModifier())
    }
}
