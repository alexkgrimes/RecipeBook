//
//  RecipeImage.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import Foundation
import SwiftUI

struct RecipeImage: View {
    @Binding var recipe: Recipe
    
    var body: some View {
       if let imageData = recipe.image, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            AsyncImage(url: recipe.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .onAppear {
                        if recipe.image == nil {
                            recipe.image = image.asUIImage().pngData()
                        }
                    }
            } placeholder: {
                Image("recipe-placeholder")
            }
        }
        
    }
}
