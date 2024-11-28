//
//  Recipe.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

final class Recipe: Identifiable, Equatable {
    
    var uuid: UUID = UUID()
    var timestamp: Date = Date.now
    var instructions: [String] = []
    var ingredients: [String] = []
    var imageURL: URL?
    var image: Data?
    var cookTime: Int?
    var cuisine: String = ""
    var prepTime: Int?
    var totalTime: Int?
    var title: String = ""
    var recipeDescription: String?
    var author: String?
    var url: URL?
    var category: String?
    var nutrients: [String: String]?
    var ratings: Double?
    var siteName: String?
    var yields: String = ""
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.uuid == rhs.uuid &&
            lhs.timestamp == rhs.timestamp &&
            lhs.instructions == rhs.instructions &&
            lhs.ingredients == rhs.ingredients &&
            lhs.imageURL == rhs.imageURL &&
            lhs.image == rhs.image &&
            lhs.cookTime == rhs.cookTime &&
            lhs.cuisine == rhs.cuisine &&
            lhs.prepTime == rhs.prepTime &&
            lhs.totalTime == rhs.totalTime &&
            lhs.title == rhs.title &&
            lhs.recipeDescription == rhs.recipeDescription &&
            lhs.author == rhs.author &&
            lhs.url == rhs.url &&
            lhs.category == rhs.category &&
            lhs.nutrients == rhs.nutrients &&
            lhs.ratings == rhs.ratings &&
            lhs.siteName == rhs.siteName &&
            lhs.yields == rhs.yields
    }
    
    init(instructions: [String], ingredients: [String], imageURL: URL?, cookTime: Int?, cuisine: String, prepTime: Int?, totalTime: Int?, title: String, recipeDescription: String?, author: String?, url: URL?, category: String?, nutrients: [String: String]?, ratings: Double?, siteName: String?, yields: String) {
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
        self.yields = recipeModel.yields ?? ""
    }
    
    init(from recipeMO: RecipeMO) {
        self.uuid = recipeMO.uuid ?? UUID()
        self.timestamp = recipeMO.timestamp ?? .now
        self.instructions = recipeMO.instructions as? [String] ?? []
        self.ingredients = recipeMO.ingredients as? [String] ?? []
        self.imageURL = recipeMO.imageURL
        self.image = recipeMO.image
        self.cookTime = Int(truncatingIfNeeded: recipeMO.cookTime)
        self.cuisine = recipeMO.cuisine ?? ""
        self.prepTime = Int(truncatingIfNeeded: recipeMO.prepTime)
        self.totalTime = Int(truncatingIfNeeded: recipeMO.totalTime)
        self.title = recipeMO.title ?? ""
        self.recipeDescription = recipeMO.recipeDescription
        self.author = recipeMO.author
        self.url = recipeMO.url
        self.category = recipeMO.category
        self.nutrients = recipeMO.nutrients as? [String: String] ?? [:]
        self.ratings = recipeMO.ratings
        self.siteName = recipeMO.siteName
        self.yields = recipeMO.yields ?? ""
    }
    
    static func emptyRecipe() -> Recipe {
        return Recipe(instructions: [], ingredients: [], imageURL: URL(string: ""), cookTime: nil, cuisine: "", prepTime: nil, totalTime: nil, title: "", recipeDescription: "", author: "", url: URL(string: ""), category: "", nutrients: [:], ratings: 0.0, siteName: "", yields: "")
    }
    
    public var hasImage: Bool {
        let noImage = self.image == nil && (self.imageURL == nil || self.imageURL?.absoluteString.isEmpty == true)
        return !noImage
    }
    
    public var canAddIngredient: Bool {
        if let last = self.ingredients.last, !last.isEmpty {
            return true
        }
        
        if ingredients.isEmpty {
            return true
        }
        
        return false
    }
    
    public var canAddStep: Bool {
        if let last = self.instructions.last, !last.isEmpty {
            return true
        }
        
        if instructions.isEmpty {
            return true
        }
        
        return false
    }
}
