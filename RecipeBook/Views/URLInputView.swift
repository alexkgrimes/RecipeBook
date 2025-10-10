//
//  URLInputView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/12/24.
//

import Foundation
import SwiftUI

enum DismissalReason {
    case cancel
    case submit
}

struct URLInputView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var url = ""
    @State private var dismissalReason: DismissalReason = .cancel
    
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
            TextField("Enter URL", text: $url)
                .keyboardType(.URL)
                .textContentType(.URL)
            
            Button {
                print("Submit")
                Task {
                    recipeViewModel.recipe = await WebService.parseRecipe(with: url)
                    dismiss()
                }
            } label: {
                Text("Submit")
            }
        }.onAppear {
            recipeViewModel.recipe = Recipe.emptyRecipe()
        }
    }
}
