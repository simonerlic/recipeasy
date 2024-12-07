//
//  APISetupView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-22.
//

import SwiftUI

struct APISetupView: View {
    @Binding var showingSettings: Bool
    @Binding var showingSubscription: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(Circle())
            
            Title2Text("AI Generation Setup Required")
                .font(.title2.bold())
            
            Text("To use the AI recipe generator, you'll need to either subscribe or provide your own OpenAI API key.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button {
                    showingSubscription = true
                } label: {
                    Label("Subscribe Now", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    showingSettings = true
                } label: {
                    Label("Use My Own API Key", systemImage: "key")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}
