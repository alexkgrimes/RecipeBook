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
    
    public func addIngredientIfNeeded(to section: String) {
        if recipe.canAddIngredient(to: section) {
            recipe.ingredients[section]?.append("")
            objectWillChange.send()
        }
    }
    
    func updateRecipe(recipe: Recipe) {
        Task {
            // This is updating a recipe that already exists
            await WebService.addRecipe(newRecipe: recipe)
            self.recipe = recipe
        }
    }
    
    func increaseYield() {
        updateYieldNumber(increment: true)
    }
    
    func decreaseYield() {
        updateYieldNumber(increment: false)
    }
    
    private func updateYieldNumber(increment: Bool) {
        let updatedYields = recipe.yields.byOffsettingNumbersBy(increment ? 1 : -1)
        print("\(updatedYields)")
        recipe.yields = updatedYields
        // TODO: actually increase the amounts as well :/
        objectWillChange.send()
    }
}

extension String {
    func byOffsettingNumbersBy(_ offset: Int) -> String {
        let scanner = Scanner(string: self)

        var output = ""

        while !scanner.isAtEnd {
            if let text = scanner.scanCharacters(from: CharacterSet.decimalDigits.inverted) {
                output += text
            } else if let int = scanner.scanInt() {
                output += String(int + offset)
            }
            
            if !scanner.isAtEnd {
                output += " "
            }
        }

        return output
    }
}
