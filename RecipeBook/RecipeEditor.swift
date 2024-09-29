//
//  RecipeEditor.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation
import SwiftUI

struct RecipeEditor: View {
    let recipe: Recipe?
    
    @State private var name = ""
    @State private var ingredients: [String] = []
    
    private var editorTitle: String {
        recipe == nil ? "Add Recipe" : "Edit Recipe"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                
                Text("Ingredients")
                ForEach(ingredients.indices, id: \.self) { index in
                    TextField("Enter ingredient", text: $ingredients[index])
                }
            }
        }
        .navigationTitle(editorTitle)
    }
}
