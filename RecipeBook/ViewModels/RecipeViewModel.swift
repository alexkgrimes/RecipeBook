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
    @Published var showErrorAlert: Bool = false
    @Published var recipe: Recipe {
        didSet {
            self.flattenedIngredients = recipe.ingredientSections.flattenedIngredients
            self.flattenedInstructions = recipe.instructionSections.flattenedInstructions
        }
    }
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published var flattenedIngredients: [FlattenedListItem] = []
    @Published var flattenedInstructions: [FlattenedListItem] = []
    
    init(recipe: Recipe? = nil) {
        self.recipe = recipe ?? Recipe.emptyRecipe()
        self.flattenedIngredients = recipe?.ingredientSections.flattenedIngredients ?? []
        self.flattenedInstructions = recipe?.instructionSections.flattenedInstructions ?? []
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

    public func addFlattenedStepIfNeeded(at index: Int) {
        if let item = flattenedInstructions[safe: index - 1], item.type == .listItem && !item.text.isEmpty {
            flattenedInstructions.insert(.init(type: .listItem, text: ""), at: index)
        }
        
        if let item = flattenedInstructions[safe: index - 1], item.type == .title {
            flattenedInstructions.insert(.init(type: .listItem, text: ""), at: index)
        }
        
        if index == 0 {
            flattenedInstructions.insert(.init(type: .listItem, text: ""), at: index)
        }
        objectWillChange.send()
        print("cannot add instruction in this state")
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
        objectWillChange.send()
        print("cannot add ingredient in this state")
    }
    
    func addFlattenedIngredientSection() {
        flattenedIngredients.append(.init(type: .title, text: "New Section"))
        flattenedIngredients.append(.init(type: .addButton, text: "Add Ingredient"))
        objectWillChange.send()
    }
    
    func addFlattenedInstructionSection() {
        flattenedInstructions.append(.init(type: .title, text: "New Section"))
        flattenedInstructions.append(.init(type: .addButton, text: "Add Step"))
        objectWillChange.send()
    }
    
    func updateRecipe() async -> Bool {
        // This is updating a recipe that already exists
        cleanUpRecipe()
        let success = await WebService.addRecipe(newRecipe: recipe)
        if !success {
            showErrorAlert = true
        }
        return success
    }
    
    func addRecipe() async -> Bool {
        print("addRecipe")
        
        cleanUpRecipe()
        let success = await WebService.addRecipe(newRecipe: recipe)
        if !success {
            showErrorAlert = true
        }
        return success
    }
    
    private func cleanUpRecipe() {
        recipe.ingredientSections = flattenedIngredients.sectionedList()
        recipe.instructionSections = flattenedInstructions.sectionedList()
        
        for sectionIndex in recipe.ingredientSections.indices {
            recipe.ingredientSections[sectionIndex].listItems = recipe.ingredientSections[sectionIndex].listItems.filter { !$0.isEmpty }
        }
        
        for sectionIndex in recipe.instructionSections.indices {
            recipe.instructionSections[sectionIndex].listItems = recipe.instructionSections[sectionIndex].listItems.filter { !$0.isEmpty }
        }
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
