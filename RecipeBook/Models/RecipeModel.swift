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
    @CodableExplicitNull var id: String?
    @CodableExplicitNull var timestamp: String?
    @CodableExplicitNull var instructionSections: [TitledList]?
    @CodableExplicitNull var ingredientSections: [TitledList]?
    @CodableExplicitNull var imageURL: URL?
    @CodableExplicitNull var imageData: String?
    @CodableExplicitNull var cookTime: Int?
    @CodableExplicitNull var cuisine: String?
    @CodableExplicitNull var prepTime: Int?
    @CodableExplicitNull var totalTime: Int?
    @CodableExplicitNull var title: String?
    @CodableExplicitNull var recipeDescription: String?
    @CodableExplicitNull var author: String?
    @CodableExplicitNull var url: String?
    @CodableExplicitNull var category: String?
    @CodableExplicitNull var nutrients: [String: String]?
    @CodableExplicitNull var siteName: String?
    @CodableExplicitNull var yields: String?
    @CodableExplicitNull var notes: String?
    @CodableExplicitNull var tags: [String]?
    @CodableExplicitNull var videoURL: String?
    
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
        self.videoURL = recipe.videoURL
    }
}
