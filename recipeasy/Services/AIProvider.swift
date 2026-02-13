//
//  AIProvider.swift
//  recipeasy
//
//  Protocol defining the interface for AI recipe generation providers
//

import Foundation

/// Errors that can occur during recipe generation
enum AIProviderError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case invalidAPIKey
    case quotaExceeded
    case serverError
    case unsupportedOnDevice
    case unsupportedLanguage

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to process recipe: \(error.localizedDescription)"
        case .apiError(let message):
            return message
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        case .quotaExceeded:
            return "API quota exceeded. Please try again later or check your subscription."
        case .serverError:
            return "AI service error. Please try again later."
        case .unsupportedOnDevice:
            return "Apple Intelligence is not available on this device. Please select OpenAI in settings."
        case .unsupportedLanguage:
            return "The selected language is not supported by Apple Intelligence."
        }
    }
}

/// Protocol for AI recipe generation providers
protocol AIProvider {
    /// The display name of the provider (e.g., "OpenAI", "Apple Intelligence")
    var name: String { get }

    /// Whether this provider is available on the current device
    var isAvailable: Bool { get }

    /// Generate a recipe from a text prompt
    /// - Parameter prompt: The user's recipe request
    /// - Returns: A generated Recipe object
    /// - Throws: AIProviderError if generation fails
    func generateRecipe(prompt: String) async throws -> Recipe
}

/// Enum to identify different AI providers
enum AIProviderType: String, Codable, CaseIterable {
    case openai = "OpenAI"
    case appleIntelligence = "Apple Intelligence"

    var displayName: String {
        self.rawValue
    }

    var description: String {
        switch self {
        case .openai:
            return "Uses OpenAI's GPT models (requires API key or subscription)"
        case .appleIntelligence:
            return "On-device generation using Apple Intelligence (iOS 26.0+, no API key needed)"
        }
    }
}
