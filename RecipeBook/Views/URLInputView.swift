//
//  URLInputView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/12/24.
//

import Foundation
import SwiftUI

struct URLInputView: View {
    @State private var url = ""
    @Binding var inProgressRecipe: Recipe
    @Environment(\.dismiss) var dismiss
    
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
            
            Button {
                print("Submit")
                Task {
                    inProgressRecipe = await WebService.fetchRecipe(with: url)
                    dismiss()
                }
            } label: {
                Text("Submit")
            }
        }.onAppear {
            inProgressRecipe = Recipe.emptyRecipe()
        }
    }
}
