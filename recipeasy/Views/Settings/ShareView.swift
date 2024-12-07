//
//  ShareView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-19.
//

import SwiftUI

struct ShareView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Share Recipe")
                    .font(.title2.bold())
                    .padding(.top)
                
                if let url = shareURL {
                    ShareLink(
                        item: url,
                        preview: SharePreview(
                            recipe.name,
                            image: recipe.imageData.map { Image(uiImage: UIImage(data: $0)!) } ?? Image(systemName: "fork.knife")
                        )
                    ) {
                        Label("Share Recipe", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recipe Link:")
                            .font(.headline)
                        
                        Text(url.absoluteString)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button(action: {
                            UIPasteboard.general.string = url.absoluteString
                        }) {
                            Label("Copy Link", systemImage: "doc.on.doc")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                } else {
                    ProgressView()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            shareURL = RecipeShareManager.createShareURL(for: recipe)
        }
    }
}
