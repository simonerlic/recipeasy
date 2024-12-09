////  RecipeCard.swift//  recipeasy////  Created by Simon Erlic on 2024-11-17.//import SwiftUIstruct RecipeCard: View {    let recipe: Recipe        var body: some View {        VStack(alignment: .leading, spacing: 0) {            ZStack(alignment: .top) {                if let imageData = recipe.imageData,                   let uiImage = UIImage(data: imageData) {                    Image(uiImage: uiImage)                        .resizable()                        .scaledToFill()                        .frame(height: 150)                        .clipped()                }            }            .frame(maxWidth: .infinity)            .clipShape(Rectangle())                        VStack(alignment: .leading, spacing: 12) {                Text(recipe.name)                    .font(.title3)                    .bold()                    .foregroundStyle(.primary)                                if !recipe.recipeDescription.isEmpty {                    Text(recipe.recipeDescription)                        .font(.subheadline)                        .lineLimit(2)                        .foregroundStyle(.secondary)                }                                HStack {                    TimeChip(minutes: recipe.cookingTimeMinutes)                    DifficultyChip(recipe: recipe)                    Spacer()                }            }            .padding()        }        .background(Color(uiColor: .secondarySystemGroupedBackground))        .clipShape(RoundedRectangle(cornerRadius: 12))        .contentShape(Rectangle())        .shadow(            color: Color(.sRGBLinear, white: 0, opacity: 0.1),            radius: 4,            x: 0,            y: 2        )    }        private var difficultyColor: Color {        switch recipe.difficulty {        case .easy:            return .green        case .medium:            return .orange        case .hard:            return .red        }    }}