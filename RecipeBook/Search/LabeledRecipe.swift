//
//  LabeledRecipe.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/27/24.
//

import Foundation

class LabeledRecipe {
    let recipe: Recipe
    let priority: Int
    
    init(recipe: Recipe, priority: Int) {
        self.recipe = recipe
        self.priority = priority
    }
}
