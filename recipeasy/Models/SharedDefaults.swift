//
//  SharedDefaults.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-03.
//


import Foundation

enum SharedDefaults {
    static let appGroup = "group.dev.serlic.recipeasy"
    static let apiKeyKey = "OPENAI_API_KEY"
    
    static var groupDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }
    
    static var apiKey: String {
        get { groupDefaults?.string(forKey: apiKeyKey) ?? "" }
        set { groupDefaults?.set(newValue, forKey: apiKeyKey) }
    }
}