//
//  RecipeBook.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/31/24.
//

import Foundation
import UIKit

final class RecipeBook: Identifiable {
    var uuid = UUID()
    var name: String = "My Recipe Book"
    var recipes: [Recipe] = []
    
    init(recipes: [Recipe]) {
        self.recipes = recipes
    }
    
    init(from recipeBookMO: RecipeBookMO) {
        self.name = recipeBookMO.name ?? ""
        
        let recipeMOs = recipeBookMO.recipes as? [RecipeMO] ?? []
        self.recipes = recipeMOs.compactMap { Recipe(from: $0) }
    }
}
