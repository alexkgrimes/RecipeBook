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
    @Published var recipe: Recipe {
        didSet {
            self.flattenedIngredients = recipe.ingredientSections.flattenedIngredients
        }
    }
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published var flattenedIngredients: [FlattenedListItem] = []
    
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
    
    func addFlattenedIngredientIfNeeded(at index: Int) {
        if let item = flattenedIngredients[safe: index - 1], item.type == .listItem && !item.text.isEmpty {
            flattenedIngredients.insert(.init(type: .listItem, text: ""), at: index)
        }
        
        if let item = flattenedIngredients[safe: index - 1], item.type == .title {
            flattenedIngredients.insert(.init(type: .listItem, text: ""), at: index)
        }
        
        if index == 0 {
            flattenedIngredients.insert(.init(type: .listItem, text: ""), at: index)
        }
        print("cannot add ingredient in this state")
    }
    
    func addFlattenedIngredientSection() {
        flattenedIngredients.append(.init(type: .title, text: "New Section"))
        flattenedIngredients.append(.init(type: .addButton, text: "Add Ingredient"))
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
        var ingredientSections = [TitledList]()
        for flattenedIngredient in flattenedIngredients {
            switch flattenedIngredient.type {
            case .title:
                ingredientSections.append(.init(sectionName: flattenedIngredient.text, listItems: []))
            case .listItem:
                if ingredientSections.isEmpty {
                    ingredientSections.append(.init(sectionName: "", listItems: []))
                }
                ingredientSections.last?.listItems.append(flattenedIngredient.text)
            case .addButton:
                continue
            }
        }
        recipe.ingredientSections = ingredientSections
        
        for sectionIndex in recipe.ingredientSections.indices {
            recipe.ingredientSections[sectionIndex].listItems = recipe.ingredientSections[sectionIndex].listItems.filter { !$0.isEmpty }
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
