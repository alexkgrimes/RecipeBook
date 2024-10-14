//
//  Recipe.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation
import SwiftData
import UIKit

@Model
final class Recipe {
    var timestamp: Date
    var instructions: [String]
    var ingredients: [String]
    var imageURL: URL?
    var image: Data?
    var cookTime: Int
    var cuisine: String
    var prepTime: Int
    var totalTime: Int
    var title: String
    var recipeDescription: String?
    var author: String?
    var url: URL?
    var category: String?
    var nutrients: [String: String]?
    var ratings: Double?
    var siteName: String?
    var yields: String?
    
    init(instructions: [String], ingredients: [String], imageURL: URL?, cookTime: Int, cuisine: String, prepTime: Int, totalTime: Int, title: String, recipeDescription: String?, author: String?, url: URL?, category: String?, nutrients: [String: String]?, ratings: Double?, siteName: String?, yields: String?) {
        self.timestamp = .now
        self.instructions = instructions
        self.ingredients = ingredients
        self.imageURL = imageURL
        self.cookTime = cookTime
        self.cuisine = cuisine
        self.prepTime = prepTime
        self.totalTime = totalTime
        self.title = title
        self.recipeDescription = recipeDescription
        self.author = author
        self.url = url
        self.category = category
        self.nutrients = nutrients
        self.ratings = ratings
        self.siteName = siteName
        self.yields = yields
    }
    
    init(from recipeModel: RecipeModel) {
        
        var instructions = [String]()
        recipeModel.instructions?.enumerateLines { (line, stop) -> () in
            instructions.append(line)
        }
        
        self.timestamp = .now
        self.instructions = instructions
        self.ingredients = recipeModel.ingredients ?? []
        self.imageURL = recipeModel.image
        self.cookTime = recipeModel.cookTime ?? 0
        self.cuisine = recipeModel.cuisine ?? ""
        self.prepTime = recipeModel.prepTime ?? 0
        self.totalTime = recipeModel.totalTime ?? 0
        self.title = recipeModel.title ?? ""
        self.recipeDescription = recipeModel.description
        self.author = recipeModel.author
        self.url = recipeModel.canonicalUrl
        self.category = recipeModel.category
        self.nutrients = recipeModel.nutrients
        self.ratings = recipeModel.ratings
        self.siteName = recipeModel.siteName
        self.yields = recipeModel.yields
    }
    
    static func emptyRecipe() -> Recipe {
        return Recipe(instructions: [], ingredients: [], imageURL: URL(string: ""), cookTime: 0, cuisine: "", prepTime: 0, totalTime: 0, title: "", recipeDescription: "", author: "", url: URL(string: ""), category: "", nutrients: [:], ratings: 0.0, siteName: "", yields: "")
    }
}
