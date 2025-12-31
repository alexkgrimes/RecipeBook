//
//  RecipePDFView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/30/25.
//

import SwiftUI

struct RecipePDFView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView()
            descriptionView()

            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1.0)
                .foregroundStyle(.tertiary)
            
            Spacer(minLength: 16.0)
            
            IngredientsView(recipeViewModel: recipeViewModel, servingMultiplier: .one)
            InstructionsView(recipeViewModel: recipeViewModel)
            NotesView(recipeViewModel: recipeViewModel)
            Spacer()
        }
        .padding([.leading, .trailing], 72) // 1 inch margins
        .frame(width: pdfPageBounds.width)
    }
    
    @ViewBuilder func headerView() -> some View {
        VStack {
            HStack(alignment: .top, spacing: 8.0) {
                let imageSize = min(UIScreen.main.bounds.width / 3, UIScreen.main.bounds.height / 3)
                RecipeImage(recipeViewModel: recipeViewModel)
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading) {
                    Text(recipeViewModel.recipe.title)
                        .foregroundStyle(.primary)
                        .font(.title2)
                        .bold()
                    if let url = recipeViewModel.recipe.url {
                        Text("\(url)")
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.accentColor)
                    }
                    Text(recipeViewModel.recipe.yields)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Spacer()
                .frame(height: 16.0)
            
            HStack(alignment: .center, spacing: 32.0) {
                VStack(alignment: .leading) {
                    if let formatString = recipeViewModel.recipe.totalTime?.timeString() {
                        Text("Total time: \(formatString)")
                    }
                    
                    if let prepTime = recipeViewModel.recipe.prepTime, let formatString = prepTime.timeString() {
                        Text("Prep time: \(formatString)")
                    }
                    
                    if let cookTime = recipeViewModel.recipe.cookTime, let formatString = cookTime.timeString() {
                        Text("Cook time: \(formatString)")
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder func descriptionView() -> some View {
        if !recipeViewModel.recipe.recipeDescription.isEmpty {
            Text(recipeViewModel.recipe.recipeDescription)
        }
    }
}
