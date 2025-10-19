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

enum FlattenedIngredientType {
    case title
    case ingredient
    case addIngredientButton
}

class FlattenedIngredient {
    var type: FlattenedIngredientType
    var text: String
    
    init(type: FlattenedIngredientType, text: String) {
        self.type = type
        self.text = text
    }
}

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published var flattenedIngredients: [FlattenedIngredient]
    
    init(recipe: Recipe? = nil) {
        self.recipe = recipe ?? Recipe.emptyRecipe()
        self.flattenedIngredients = recipe?.flattenedIngredients ?? []
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
    
    func addFlattenedIngredientIfNeeded(at index: Int) {
        if let item = flattenedIngredients[safe: index - 1], item.type == .ingredient && !item.text.isEmpty {
            flattenedIngredients.insert(.init(type: .ingredient, text: ""), at: index)
        }
        
        if let item = flattenedIngredients[safe: index - 1], item.type == .title {
            flattenedIngredients.insert(.init(type: .ingredient, text: ""), at: index)
        }
        
        if index == 0 {
            flattenedIngredients.insert(.init(type: .ingredient, text: ""), at: index)
        }
        print("cannot add ingredient in this state")
    }
    
    func addIngredientSection() {
        recipe.ingredientSections.append(IngredientSection(sectionName: "Section Name", ingredients: []))
        objectWillChange.send()
    }
    
    func addFlattenedIngredientSection() {
        flattenedIngredients.append(.init(type: .title, text: "New Section"))
        flattenedIngredients.append(.init(type: .addIngredientButton, text: "Add Ingredient"))
        objectWillChange.send()
    }
    
    // TODO: this should probably return a recipe, success/failure
    func updateRecipe() async  {
        Task {
            // This is updating a recipe that already exists
            cleanUpRecipe()
            return await WebService.addRecipe(newRecipe: recipe)
        }
    }
    
    // TODO: this should probably return a recipe, success/failure
    func addRecipe() async {
        print("addRecipe")
        
        cleanUpRecipe()
        return await WebService.addRecipe(newRecipe: recipe)
    }
    
    private func cleanUpRecipe() {
        var ingredientSections = [IngredientSection]()
        for flattenedIngredient in flattenedIngredients {
            switch flattenedIngredient.type {
            case .title:
                ingredientSections.append(.init(sectionName: flattenedIngredient.text, ingredients: []))
            case .ingredient:
                if ingredientSections.isEmpty {
                    ingredientSections.append(.init(sectionName: "", ingredients: []))
                }
                ingredientSections.last?.ingredients.append(flattenedIngredient.text)
            case .addIngredientButton:
                continue
            }
        }
        recipe.ingredientSections = ingredientSections
        
        for sectionIndex in recipe.ingredientSections.indices {
            recipe.ingredientSections[sectionIndex].ingredients = recipe.ingredientSections[sectionIndex].ingredients.filter { !$0.isEmpty }
        }
        recipe.instructions = recipe.instructions.filter { !$0.isEmpty }
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
