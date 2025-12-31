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
                .scaledToFill()
        } else {
            AsyncImage(url: recipeViewModel.recipe.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .onAppear {
                        print("Using async image from URL")
                        if recipeViewModel.recipe.image == nil {
                            // Create an ImageRenderer with your SwiftUI Image
                            let renderer = ImageRenderer(content: image)
                            if let uiImage = renderer.uiImage, let pngData = uiImage.pngData() {
                                recipeViewModel.recipe.image = pngData
                            }
                        }
                    }
            } placeholder: {
                Image("recipe-placeholder")
            }
        }
        
    }
}
