//
//  RecipeRowView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    @State var displayDetail: Bool = false
    
    var body: some View {
        HStack {
            RecipeImage(recipe: recipe)
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .foregroundStyle(.green)
                    .bold()
                Text("\(recipe.totalTime) mins")
                    .font(.caption)
                Text("\(recipe.cuisine)")
                    .font(.caption)
                
                Spacer()
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
