//
//  Recipe.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation
import SwiftData

@Model
final class Recipe {
    var instructions: [String]
    var ingredients: [String]
    var imageURL: URL
    
    init(instructions: [String], ingredients: [String], imageURL: URL) {
        self.instructions = instructions
        self.ingredients = ingredients
        self.imageURL = imageURL
    }
}
