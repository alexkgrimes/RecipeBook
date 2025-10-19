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
    
    public func addIngredientIfNeeded(to section: Int) {
        if recipe.canAddIngredient(to: section) {
            recipe.ingredientSections[safe: section]?.ingredients.append("")
            objectWillChange.send()
        }
    }
    
    func addIngredientSection() {
        recipe.ingredientSections.append(IngredientSection(sectionName: "Section Name", ingredients: []))
        
        objectWillChange.send()
    }
    
    // TODO: this should probably return a recipe, success/failure
    func updateRecipe() async  {
        Task {
            // This is updating a recipe that already exists
            return await WebService.addRecipe(newRecipe: recipe)
        }
    }
    
    // TODO: this should probably return a recipe, success/failure
    func addRecipe() async {
        print("addRecipe")
        for sectionIndex in recipe.ingredientSections.indices {
            recipe.ingredientSections[sectionIndex].ingredients = recipe.ingredientSections[sectionIndex].ingredients.filter { !$0.isEmpty }
        }
        recipe.instructions = recipe.instructions.filter { !$0.isEmpty }
        return await WebService.addRecipe(newRecipe: recipe)
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
