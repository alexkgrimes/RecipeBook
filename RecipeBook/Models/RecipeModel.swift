//
//  RecipeModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

struct ScrapedRecipeModel: Decodable {
    let instructions: String?
    let ingredients: [String]?
    let image: URL?
    let cookTime: Int?
    let cuisine: String?
    let prepTime: Int?
    let totalTime: Int?
    let title: String?
    let description: String?
    let author: String?
    let canonicalUrl: URL?
    let category: String?
    let host: String?
    let nutrients: [String: String]?
    let siteName: String?
    let yields: String?
}

struct RecipeModel: Codable {
    let id: String?
    let timestamp: String?
    let instructionSections: [TitledList]?
    let ingredientSections: [TitledList]?
    let imageURL: URL?
    let imageData: String?
    let cookTime: Int?
    let cuisine: String?
    let prepTime: Int?
    let totalTime: Int?
    let title: String?
    let recipeDescription: String?
    let author: String?
    let url: String?
    let category: String?
    let nutrients: [String: String]?
    let siteName: String?
    let yields: String?
    let notes: String?
    let tags: [String]?
    
    init(from recipe: Recipe) {
        self.id = recipe.uuid.uuidString
        self.timestamp = recipe.timestamp.ISO8601Format()
        self.instructionSections = recipe.instructionSections
        self.ingredientSections = recipe.ingredientSections
        self.imageURL = recipe.imageURL
        self.imageData = recipe.image?.base64EncodedString()
        self.cookTime = recipe.cookTime
        self.cuisine = recipe.cuisine
        self.prepTime = recipe.prepTime
        self.totalTime = recipe.totalTime
        self.title = recipe.title
        self.recipeDescription = recipe.recipeDescription
        self.author = recipe.author
        self.url = recipe.url?.absoluteString
        self.category = recipe.category
        self.nutrients = recipe.nutrients
        self.siteName = recipe.siteName
        self.yields = recipe.yields
        self.notes = recipe.notes
        self.tags = recipe.tags
    }
}
