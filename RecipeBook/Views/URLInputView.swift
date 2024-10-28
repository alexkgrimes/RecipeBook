//
//  URLInputView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/12/24.
//

import Foundation
import SwiftUI

struct URLInputView: View {
    @Binding var newRecipe: Recipe
    @Environment(\.dismiss) var dismiss
    
    @State private var url = ""
    
    var body: some View {
        NavigationStack {
            urlEntryForm
                .navigationTitle("Add Recipe")
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
                    newRecipe = await WebService.fetchRecipe(with: url)
                    dismiss()
                }
            } label: {
                Text("Submit")
            }
        }.onAppear {
            newRecipe = Recipe.emptyRecipe()
        }
    }
}
