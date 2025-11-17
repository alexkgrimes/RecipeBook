//
//  URLInputView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/12/24.
//

import Foundation
import SwiftUI

struct URLInputView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var url = ""
    @State private var parseAlert: Bool = false
    var submitCompletion: (() -> ())?
    
    var body: some View {
        NavigationStack {
            urlEntryForm
                .navigationTitle("Add Recipe")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    var urlEntryForm: some View {
        Form {
            Section {
                TextField("Enter URL", text: $url)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                
                Button {
                    parseRecipe()
                } label: {
                    Text("Submit")
                }
            }

            Section {
                Button {
                    dismiss() {
                        submitCompletion?()
                    }
                } label: {
                    Text("Manual Entry")
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .onAppear {
            recipeViewModel.recipe = Recipe.emptyRecipe()
        }
        .alert("Parse Failure", isPresented: $parseAlert) {
            Button("Enter Manually") {
                dismiss() {
                    submitCompletion?()
                }
            }
        } message: {
            Text("Failed to parse recipe from URL.")
        }
    }
    
    private func parseRecipe() {
        print("Submit")
        Task {
            let (recipe, success) = await WebService.parseRecipe(with: url)
            recipeViewModel.recipe = recipe
            guard success else {
                parseAlert = true
                return
            }
            dismiss() {
                submitCompletion?()
            }
        }
    }
    
    private func dismiss(completion: (() -> ())?) {
        dismiss()
        completion?()
    }
}
