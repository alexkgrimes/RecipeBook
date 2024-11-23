//
//  RecipeRowView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI
import CoreData

struct RecipeRowView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @State var displayDetail: Bool = false
    
    init(recipe: Recipe, managedObjectContext: NSManagedObjectContext) {
        recipeViewModel = RecipeViewModel(recipe: recipe, managedObjectContext: managedObjectContext)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            RecipeImage(recipeViewModel: recipeViewModel)
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(recipeViewModel.recipe.title)
                    .foregroundStyle(.green)
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
        }
        .onTapGesture {
            displayDetail = true
        }
        .sheet(isPresented: $displayDetail) {
            RecipeDetailView(recipeViewModel: recipeViewModel)
        }
    }
}
