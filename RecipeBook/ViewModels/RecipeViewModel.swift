//
//  HomeViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
final class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe = Recipe.emptyRecipe()
    
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection = selection else {
            return
        }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                recipe.image = data
            }
        }
    }
    
    public func addStepIfNeeded() {
        if recipe.canAddStep {
            recipe.instructions.append("")
        }
    }
    
    public func addIngredientIfNeeded() {
        if recipe.canAddIngredient {
            recipe.ingredients.append("")
        }
    }
}
