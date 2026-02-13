//
//  OpenAIProvider.swift
//  recipeasy
//
//  OpenAI implementation of the AIProvider protocol
//

import Foundation

class OpenAIProvider: AIProvider {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let maxRetries = 3

    var name: String {
        "OpenAI"
    }

    var isAvailable: Bool {
        !apiKey.isEmpty
    }

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateRecipe(prompt: String) async throws -> Recipe {
        guard !apiKey.isEmpty else {
            throw AIProviderError.invalidAPIKey
        }

        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                return try await generateRecipeAttempt(prompt: prompt)
            } catch let error as AIProviderError {
                // Don't retry for specific API errors
                switch error {
                case .invalidAPIKey, .quotaExceeded, .serverError, .apiError:
                    throw error
                default:
                    lastError = error
                    if attempt < maxRetries {
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                        continue
                    }
                }
            } catch {
                lastError = error
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    continue
                }
            }
        }

        throw lastError ?? AIProviderError.invalidResponse
    }

    private func generateRecipeAttempt(prompt: String) async throws -> Recipe {
        guard !apiKey.isEmpty else {
            throw AIProviderError.invalidAPIKey
        }

        guard let url = URL(string: baseURL) else {
            throw AIProviderError.invalidURL
        }

        let systemPrompt = """
        You are a helpful cooking assistant. Generate detailed recipes with exact measurements, step-by-step instructions, difficulty ratings, and cooking tips.
        Follow the schema exactly and provide all required fields.
        Ensure all measurements are precise with numeric values.
        Keep step descriptions clear and concise.
        Include relevant cooking tips in the notes field.
        Ensure you set the difficulty level accordingly, with "easy" being quick and beginner friendly, "medium" being achievable for a home chef, and "hard" being fairly difficult or lengthy for the average person.
        """

        let messages = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": prompt]
        ]

        // Define the JSON schema for the response
        let jsonSchema: [String: Any] = [
            "name": "recipe_response",
            "type": "object",
            "properties": [
                "name": ["type": "string"],
                "description": ["type": "string"],
                "cookingTimeMinutes": ["type": "integer", "minimum": 1],
                "difficulty": ["type": "string", "enum": ["Easy", "Medium", "Hard"]],
                "ingredients": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "name": ["type": "string"],
                            "amount": ["type": "number", "minimum": 0],
                            "unit": ["type": "string"],
                            "notes": ["type": ["string", "null"]]
                        ],
                        "required": ["name", "amount", "unit"]
                    ]
                ],
                "steps": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "orderIndex": ["type": "integer", "minimum": 0],
                            "description": ["type": "string"],
                            "durationMinutes": ["type": ["integer", "null"], "minimum": 1],
                            "notes": ["type": ["string", "null"]]
                        ],
                        "required": ["orderIndex", "description"]
                    ]
                ],
                "notes": ["type": "string"]
            ],
            "required": ["name", "description", "cookingTimeMinutes", "difficulty", "ingredients", "steps", "notes"]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7,
            "response_format": [
                "type": "json_schema",
                "json_schema": [
                    "name": "recipe_response",
                    "schema": jsonSchema
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch let serializationError {
            throw AIProviderError.networkError(serializationError)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Handle HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success case, continue processing
                case 401:
                    throw AIProviderError.invalidAPIKey
                case 429:
                    throw AIProviderError.quotaExceeded
                case 500...599:
                    throw AIProviderError.serverError
                default:
                    if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                        throw AIProviderError.apiError(errorResponse.error.message)
                    } else {
                        throw AIProviderError.invalidResponse
                    }
                }
            }

            let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
            guard let recipeJSON = aiResponse.choices.first?.message.content else {
                throw AIProviderError.apiError("No recipe generated")
            }

            return try parseRecipeJSON(recipeJSON)

        } catch let urlError as URLError {
            throw AIProviderError.networkError(urlError)
        } catch let recipeError as AIProviderError {
            throw recipeError
        } catch let otherError {
            throw AIProviderError.networkError(otherError)
        }
    }

    private func parseRecipeJSON(_ json: String) throws -> Recipe {
        guard let jsonData = json.data(using: .utf8) else {
            throw AIProviderError.decodingError(NSError(domain: "", code: -1))
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

            guard let difficulty = DifficultyLevel(rawValue: recipeData.difficulty) else {
                throw AIProviderError.decodingError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid difficulty level"]))
            }

            return Recipe(
                name: recipeData.name,
                recipeDescription: recipeData.description,
                ingredients: ingredients,
                steps: steps,
                cookingTimeMinutes: recipeData.cookingTimeMinutes,
                difficulty: difficulty,
                notes: recipeData.notes,
                isAIGenerated: true
            )
        } catch let decodingError {
            throw AIProviderError.decodingError(decodingError)
        }
    }
}

// Response structures for error handling
private struct OpenAIErrorResponse: Codable {
    let error: OpenAIError

    struct OpenAIError: Codable {
        let message: String
        let type: String?
        let code: String?
    }
}
