//
//  RecipeViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/9/24.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
class RecipeViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    
    @Published var recipe: Recipe
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    init(recipe: Recipe? = nil) {
        self.recipe = recipe ?? Recipe.emptyRecipe()
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection = selection else {
            return
        }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                recipe.image = data
                objectWillChange.send()
            }
        }
    }

    public func addStepIfNeeded() {
        if recipe.canAddStep {
            recipe.instructions.append("")
            objectWillChange.send()
        }
    }
    
    public func addIngredientIfNeeded() {
        if recipe.canAddIngredient {
            recipe.ingredients.append("")
            objectWillChange.send()
        }
    }
    
    func updateRecipe(recipe: Recipe) {
        Task {
            // This is updating a recipe that already exists
            await WebService.addRecipe(newRecipe: recipe)
            // TODO: reload data?
        }
   }
}
