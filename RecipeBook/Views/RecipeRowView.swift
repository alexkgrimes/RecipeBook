//
//  RecipeRowView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeRowView: View {
    @State var recipe: Recipe
    @State var displayDetail: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            RecipeImage(recipe: $recipe)
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(recipe.title)
                    .foregroundStyle(.green)
                    .bold()
                
                if let cookTime = recipe.cookTime {
                    Text("Cook time: \(cookTime) mins")
                        .font(.caption)
                }
                
                if let totalTime = recipe.totalTime {
                    Text("Total time: \(totalTime) mins")
                        .font(.caption)
                }
                
                Text("\(recipe.cuisine)")
                    .font(.caption)
            }
        }
        .onTapGesture {
            displayDetail = true
        }
        .sheet(isPresented: $displayDetail) {
            RecipeDetailView(recipe: recipe)
        }
    }
}
