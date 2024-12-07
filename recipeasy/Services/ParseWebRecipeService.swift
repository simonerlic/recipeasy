//
//  LLMRecipeService.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-20.
//


import Foundation

class ParseWebRecipeService {
    private let aiService: AIRecipeService
    
    init(apiKey: String) {
        self.aiService = AIRecipeService(apiKey: apiKey)
    }
    
    func parseRecipeFromHTML(_ html: String) async throws -> Recipe {
        // Clean HTML by removing scripts, styles, and comments
        let cleanHTML = cleanHTML(html)
        
        let prompt = """
        Extract the recipe from this HTML and format it as JSON. Ensure the difficulty is set accordingly. Here's the webpage content:
        
        \(cleanHTML)
        
        Return only valid JSON in this format:
        {
            "name": "Recipe name",
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
        """
        
        // Reuse existing API service but bypass its system prompt
        return try await aiService.generateRecipe(prompt: prompt)
    }
    
    private func cleanHTML(_ html: String) -> String {
        var cleaned = html
            .replacingOccurrences(of: #"<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"<!--[\s\S]*?-->"#, with: "", options: .regularExpression)
        
        // Remove HTML tags but preserve text content
        cleaned = cleaned.replacingOccurrences(of: #"<[^>]+>"#, with: "\n", options: .regularExpression)
        
        // Clean up whitespace
        cleaned = cleaned
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}
