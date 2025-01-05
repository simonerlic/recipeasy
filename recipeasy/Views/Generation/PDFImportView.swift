//
//  PDFImportView.swift
//  recipeasy
//
//  Created by Simon Erlic on 2025-01-03.
//


import SwiftUI
import UniformTypeIdentifiers

struct PDFImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("OPENAI_API_KEY") private var userApiKey = ""
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var isShowingPDFPicker = false
    @State private var selectedPDFURL: URL?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingError = false
    @State private var showingSubscription = false
    @State private var showingSettings = false
    
    private let subscriberApiKey = APIEnv.apiKey
    
    private var activeApiKey: String {
        subscriptionService.hasActiveSubscription ? subscriberApiKey : userApiKey
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !subscriptionService.hasActiveSubscription && userApiKey.isEmpty {
                    APISetupView(
                        showingSettings: $showingSettings,
                        showingSubscription: $showingSubscription
                    )
                } else {
                    // Header section
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Have a recipe in a PDF format that you love? Import it into Recipeasy here.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // PDF selection button
                    Button(action: {
                        if !isLoading {
                            isShowingPDFPicker = true
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                Text("Generating Recipe...")
                            } else {
                                Image(systemName: "doc.badge.plus")
                                Text(selectedPDFURL == nil ? "Select PDF" : "Change PDF")
                            }
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    
                    if let url = selectedPDFURL {
                        Text(url.lastPathComponent)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Import from PDF")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            if let _ = selectedPDFURL {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        Task {
                            await importPDF()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
        .fileImporter(
            isPresented: $isShowingPDFPicker,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedPDFURL = url
                }
            case .failure(let error):
                self.error = error
                showingError = true
            }
        }
        .alert("Import Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func importPDF() async {
        guard let url = selectedPDFURL else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let service = PDFRecipeService(apiKey: activeApiKey)
            let recipe = try await service.parseRecipeFromPDF(url: url)
            
            // Save recipe
            modelContext.insert(recipe)
            dismiss()
        } catch {
            self.error = error
            showingError = true
        }
    }
}
