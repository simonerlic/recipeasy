//
//  AddRecipeOptionsView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-21.
//

import SwiftUI

import SwiftUI

struct NewRecipeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingManualEntry = false
    @State private var showingAIGeneration = false
    @State private var showingImportModal = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                            .padding(.top)
                        
                        Text("Create New Recipe")
                            .font(.title2.bold())
                        
                        Text("Choose how you'd like to create your recipe")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Manual Entry Option
                        Button(action: { showingManualEntry = true }) {
                            RecipeCreationOptionCard(
                                icon: "square.and.pencil",
                                title: "Manual Entry",
                                description: "Create a recipe from scratch with your own ingredients and steps",
                                color: .blue
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // AI Generation Option
                        Button(action: { showingAIGeneration = true }) {
                            RecipeCreationOptionCard(
                                icon: "wand.and.stars",
                                title: "AI Generator",
                                description: "Let AI help you create a recipe based on your preferences",
                                color: .purple
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Import Option
                        Button(action: { showingImportModal = true }) {
                            RecipeCreationOptionCard(
                                icon: "link",
                                title: "Import from Website",
                                description: "Import a recipe directly from your favorite cooking websites",
                                color: .green
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                }
                .padding()
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                NavigationStack {
                    AddRecipeView()
                }
            }
            .sheet(isPresented: $showingAIGeneration) {
                NavigationStack {
                    GenerateRecipeView()
                }
            }
            .sheet(isPresented: $showingImportModal) {
                ImportRecipeView()
                    .presentationDetents([.medium])
            }
        }
    }
}

struct RecipeCreationOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
                .frame(width: 64, height: 64)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NewRecipeSelectorView()
}
