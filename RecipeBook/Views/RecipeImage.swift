//
//  RecipeImage.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import Foundation
import SwiftUI

struct RecipeImage: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    var body: some View {
        if let imageData = recipeViewModel.recipe.image, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            AsyncImage(url: recipeViewModel.recipe.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        if recipeViewModel.recipe.image == nil {
                            recipeViewModel.recipe.image = image.asUIImage().pngData()
                        }
                    }
            } placeholder: {
                Image("recipe-placeholder")
            }
        }
        
    }
}
