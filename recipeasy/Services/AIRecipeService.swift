//
//  AIRecipeService.swift
//  recipeasy
//

import Foundation

enum AIRecipeError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case invalidAPIKey
    case quotaExceeded
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from server"
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
            return "OpenAI server error. Please try again later."
        }
    }
}

struct AIRecipeService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateRecipe(prompt: String) async throws -> Recipe {
        guard !apiKey.isEmpty else {
            throw AIRecipeError.invalidAPIKey
        }
        
        guard let url = URL(string: baseURL) else {
            throw AIRecipeError.invalidURL
        }
        
        let messages = [
            ["role": "system", "content": """
            You are a helpful cooking assistant. Generate detailed recipes with exact measurements, step-by-step instructions, difficulty ratings, and cooking tips.
            Respond in the following JSON format:
            {
                "name": "Recipe Name",
                "description": "Brief description",
                "cookingTimeMinutes": 30,
                "difficulty": "easy|medium|hard",
                "ingredients": [
                    {
                        "name": "Ingredient name",
                        "amount": 2.0,
                        "unit": "cups",
                        "notes": "optional notes"
                    }
                ],
                "steps": [
                    {
                        "orderIndex": 0,
                        "description": "Step description",
                        "durationMinutes": 5,
                        "notes": "optional notes"
                    }
                ],
                "notes": "Additional tips and notes"
            }
            
            Ensure all measurements are precise and ingredient amounts are numeric values.
            Keep step descriptions clear and concise.
            Include relevant cooking tips and notes.
            Adjust difficulty based on complexity and required skill level.
            """],
            ["role": "user", "content": prompt]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch let serializationError {
            throw AIRecipeError.networkError(serializationError)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success case, continue processing
                case 401:
                    throw AIRecipeError.invalidAPIKey
                case 429:
                    throw AIRecipeError.quotaExceeded
                case 500...599:
                    throw AIRecipeError.serverError
                default:
                    // Try to get error message from response
                    if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                        throw AIRecipeError.apiError(errorResponse.error.message)
                    } else {
                        throw AIRecipeError.invalidResponse
                    }
                }
            }
            
            let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
            guard let recipeJSON = aiResponse.choices.first?.message.content else {
                throw AIRecipeError.apiError("No recipe generated")
            }
            
            return try parseRecipeJSON(recipeJSON)
            
        } catch let urlError as URLError {
            throw AIRecipeError.networkError(urlError)
        } catch let recipeError as AIRecipeError {
            throw recipeError
        } catch let otherError {
            throw AIRecipeError.networkError(otherError)
        }
    }
    
    private func parseRecipeJSON(_ json: String) throws -> Recipe {
        guard let jsonData = json.data(using: .utf8) else {
            throw AIRecipeError.decodingError(NSError(domain: "", code: -1))
        }
        
        do {
            let decoder = JSONDecoder()
            let recipeData = try decoder.decode(AIRecipeData.self, from: jsonData)
            
            // Convert AIRecipeData to Recipe model
            let ingredients = recipeData.ingredients.map { ingredient in
                Ingredient(
                    name: ingredient.name,
                    amount: ingredient.amount,
                    unit: ingredient.unit,
                    notes: ingredient.notes
                )
            }
            
            let steps = recipeData.steps.map { step in
                CookingStep(
                    orderIndex: step.orderIndex,
                    stepDescription: step.description,
                    durationMinutes: step.durationMinutes,
                    notes: step.notes
                )
            }
            
            return Recipe(
                name: recipeData.name,
                recipeDescription: recipeData.description,
                ingredients: ingredients,
                steps: steps,
                cookingTimeMinutes: recipeData.cookingTimeMinutes,
                difficulty: DifficultyLevel(rawValue: recipeData.difficulty.lowercased()) ?? .medium,
                notes: recipeData.notes,
                isAIGenerated: true
            )
        } catch let decodingError {
            throw AIRecipeError.decodingError(decodingError)
        }
    }
}

// Response structures for error handling
struct OpenAIErrorResponse: Codable {
    let error: OpenAIError
    
    struct OpenAIError: Codable {
        let message: String
        let type: String?
        let code: String?
    }
}
