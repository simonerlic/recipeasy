//
//  SmallRecipeWidget.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-26.
//

import SwiftUI
import WidgetKit

struct SmallRecipeWidget: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
                .lineLimit(3)
            
            Spacer()

            HStack{
                HStack {
                    Image(systemName: "clock")
                        .imageScale(.small)
                    Text("\(recipe.cookingTimeMinutes)m")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                
                
                HStack {
                    Image(systemName: "chart.bar")
                        .imageScale(.small)
                    Text(recipe.difficulty.rawValue)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .widgetURL(URL(string: "recipeasy://recipe/\(recipe.id.uuidString)"))
    }
}

struct MediumRecipeWidget: View {
    let recipe: Recipe
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if let imageData = recipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: processImageForWidget(uiImage))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(recipe.recipeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "clock")
                            .imageScale(.small)
                        Text("\(recipe.cookingTimeMinutes)m")
                        
                        Spacer()
                        
                        Image(systemName: "chart.bar")
                            .imageScale(.small)
                        Text(recipe.difficulty.rawValue)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.leading, recipe.imageData != nil ? 16 : 0)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .widgetURL(URL(string: "recipeasy://recipe/\(recipe.id.uuidString)"))
    }
    
    private func processImageForWidget(_ image: UIImage) -> UIImage {
        let maxDimension: CGFloat = 400
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

//#Preview(as: .systemSmall) {
//    RandomRecipeWidget()
//} timeline: {
//    RandomRecipeEntry(date: .now, recipe: Recipe.placeholder)
//}
