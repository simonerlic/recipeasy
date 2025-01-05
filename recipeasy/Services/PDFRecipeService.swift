//
//  PDFRecipeService.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-03.
//


import Foundation
import PDFKit

class PDFRecipeService {
    private let aiService: AIRecipeService
    
    init(apiKey: String) {
        self.aiService = AIRecipeService(apiKey: apiKey)
    }
    
    func parseRecipeFromPDF(url: URL) async throws -> Recipe {
        guard let pdf = PDFDocument(url: url) else {
            throw ImportError.invalidPDF
        }
        
        var text = ""
        let pageCount = pdf.pageCount
        
        // Extract text from each page
        for i in 0..<pageCount {
            if let page = pdf.page(at: i) {
                if let pageText = page.string {
                    text += pageText + "\n"
                }
            }
        }
        
        // Clean extracted text
        text = text.replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print(text)
        
        let prompt = """
        Extract the recipe from this raw text and format it as JSON. Ensure the difficulty is set accordingly.
        Here's the content:
        
        \(text)
        
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
        
        return try await aiService.generateRecipe(prompt: prompt)
    }
}

enum ImportError: LocalizedError {
    case invalidPDF
    
    var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "Unable to read PDF file. Please make sure it's a valid PDF document."
        }
    }
}
