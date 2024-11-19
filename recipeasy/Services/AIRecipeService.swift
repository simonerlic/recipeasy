//
//  AIRecipeError.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//

import Foundation

enum AIRecipeError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
}

struct AIRecipeService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateRecipe(prompt: String) async throws -> Recipe {
        guard let url = URL(string: baseURL) else {
            throw AIRecipeError.invalidURL
        }
        
        let messages = [
            ["role": "system", "content": """
            You are a helpful cooking assistant. Generate detailed recipes with exact measurements, step-by-step instructions, and cooking tips.
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
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AIRecipeError.invalidResponse
        }
        
        let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
        let recipeJSON = aiResponse.choices.first?.message.content ?? ""
        
        return try parseRecipeJSON(recipeJSON)
    }
    
    private func parseRecipeJSON(_ json: String) throws -> Recipe {
        guard let jsonData = json.data(using: .utf8) else {
            throw AIRecipeError.decodingError(NSError(domain: "", code: -1))
        }
        
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
    }
}
