//
//  SettingsView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-18.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("OPENAI_API_KEY") private var apiKey = ""
    @State private var showingApiKey = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    VStack(alignment: .leading, spacing: 8) {
                        if showingApiKey {
                            TextField("OpenAI API Key", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("OpenAI API Key", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        Toggle("Show API Key", isOn: $showingApiKey)
                            .toggleStyle(.switch)
                        
                        Link("Get an API key", destination: URL(string: "https://platform.openai.com/api-keys")!)
                            .font(.caption)
                    }
                } footer: {
                    Text("Required for AI recipe generation. Your API key is stored securely on your device.")
                }
                
                Section {
                    Label("Version 1.0.0", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Made with ❤️ by Simon")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
