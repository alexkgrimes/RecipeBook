//
//  RecipeRowView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeRowView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @State var displayDetail: Bool = false
    
    init(recipe: Recipe) {
        recipeViewModel = RecipeViewModel(recipe: recipe)
    }
    
    var body: some View {
        NavigationLink {
            RecipeContainerView(recipeViewModel: recipeViewModel)
        } label: {
            HStack(alignment: .top) {
                RecipeImage(recipeViewModel: recipeViewModel)
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading) {
                    Text(recipeViewModel.recipe.title)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.accentColor)
                        .bold()
                    
                    if let cookTime = recipeViewModel.recipe.cookTime {
                        Text("Cook time: \(cookTime) mins")
                            .font(.caption)
                    }
                    
                    if let totalTime = recipeViewModel.recipe.totalTime {
                        Text("Total time: \(totalTime) mins")
                            .font(.caption)
                    }
                    
                    Text("\(recipeViewModel.recipe.cuisine)")
                        .font(.caption)
                }
                
                Spacer()
            }
        }
    }
}
