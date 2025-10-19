//
//  Recipe.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

final class IngredientSection: Equatable, Codable, Identifiable, Hashable, Copyable {
    var id: UUID = UUID()
    var sectionName: String = ""
    var ingredients: [String] = []
    
    init(sectionName: String, ingredients: [String]) {
        self.sectionName = sectionName
        self.ingredients = ingredients
    }
    
    static func == (lhs: IngredientSection, rhs: IngredientSection) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.sectionName != rhs.sectionName {
            return false
        }
        if lhs.ingredients.count != rhs.ingredients.count {
            return false
        }
        for (i, lhsIngredient) in lhs.ingredients.enumerated() {
            if lhsIngredient != rhs.ingredients[i] {
                return false
            }
        }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(sectionName)
        hasher.combine(ingredients)
    }
    
    func mutableCopy() -> IngredientSection {
        return IngredientSection(sectionName: self.sectionName, ingredients: self.ingredients)
    }
}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

final class Recipe: Identifiable, Equatable, Copyable {
    
    var uuid: UUID
    var timestamp: Date = Date.now
    var instructions: [String] = []
    var ingredientSections: [IngredientSection] = []
    var imageURL: URL?
    var image: Data?
    var cookTime: Int?
    var cuisine: String = ""
    var prepTime: Int?
    var totalTime: Int?
    var title: String = ""
    var recipeDescription: String = ""
    var author: String?
    var url: URL?
    var category: String?
    var nutrients: [String: String]?
    var siteName: String?
    var yields: String = ""
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.uuid == rhs.uuid &&
            lhs.timestamp == rhs.timestamp &&
            lhs.instructions == rhs.instructions &&
            lhs.ingredientSections == rhs.ingredientSections &&
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
            lhs.siteName == rhs.siteName &&
            lhs.yields == rhs.yields
    }
    
    init(uuid: UUID, instructions: [String], ingredientSections: [IngredientSection], imageURL: URL?, cookTime: Int?, cuisine: String, prepTime: Int?, totalTime: Int?, title: String, recipeDescription: String, author: String?, url: URL?, category: String?, nutrients: [String: String]?, siteName: String?, yields: String) {
        self.uuid = uuid
        self.timestamp = .now
        self.instructions = instructions
        self.ingredientSections = ingredientSections
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
        self.siteName = siteName
        self.yields = yields
    }
    
    init(from scrapedRecipeModel: ScrapedRecipeModel) {
        self.uuid = UUID()
        var instructions = [String]()
        scrapedRecipeModel.instructions?.enumerateLines { (line, stop) -> () in
            instructions.append(line)
        }
        
        self.timestamp = .now
        self.instructions = instructions
        if let ingredients = scrapedRecipeModel.ingredients {
            self.ingredientSections = [IngredientSection(sectionName: "", ingredients: ingredients)]
        }
        self.imageURL = scrapedRecipeModel.image
        self.cookTime = scrapedRecipeModel.cookTime ?? 0
        self.cuisine = scrapedRecipeModel.cuisine ?? ""
        self.prepTime = scrapedRecipeModel.prepTime ?? 0
        self.totalTime = scrapedRecipeModel.totalTime ?? 0
        self.title = scrapedRecipeModel.title ?? ""
        self.recipeDescription = scrapedRecipeModel.description ?? ""
        self.author = scrapedRecipeModel.author
        self.url = scrapedRecipeModel.canonicalUrl
        self.category = scrapedRecipeModel.category
        self.nutrients = scrapedRecipeModel.nutrients
        self.siteName = scrapedRecipeModel.siteName
        self.yields = scrapedRecipeModel.yields ?? ""
    }
    
    init(from recipeModel: RecipeModel) {
        if let uuid = recipeModel.id {
            self.uuid = UUID(uuidString: uuid) ?? UUID()
        } else {
            self.uuid = UUID()
        }
        if let timestamp = recipeModel.timestamp {
            self.timestamp =  ISO8601DateFormatter().date(from: timestamp) ?? Date.now
        }
        self.instructions = recipeModel.instructions ?? []
        self.ingredientSections = recipeModel.ingredientSections ?? []
        self.imageURL = recipeModel.imageURL
        let base64EncodedString = recipeModel.imageData
        if let base64EncodedString, let data = Data(base64Encoded: base64EncodedString) {
            self.image = data
        }
        self.cookTime = recipeModel.cookTime
        self.cuisine = recipeModel.cuisine ?? ""
        self.prepTime = recipeModel.prepTime
        self.totalTime = recipeModel.totalTime
        self.title = recipeModel.title ?? ""
        self.recipeDescription = recipeModel.recipeDescription ?? ""
        self.author = recipeModel.author
        if let urlString = recipeModel.url {
            self.url = URL(string: urlString)
        }
        self.category = recipeModel.category
        self.nutrients = recipeModel.nutrients
        self.siteName = recipeModel.siteName
        self.yields = recipeModel.yields ?? ""
    }
    
    static func emptyRecipe() -> Recipe {
        return Recipe(uuid: UUID(), instructions: [], ingredientSections: [], imageURL: URL(string: ""), cookTime: nil, cuisine: "", prepTime: nil, totalTime: nil, title: "", recipeDescription: "", author: "", url: URL(string: ""), category: "", nutrients: [:], siteName: "", yields: "")
    }
    
    public func mutableCopy() -> Recipe {
        let ingredientSections = self.ingredientSections.map { $0.mutableCopy() }
        let nutrients = self.nutrients
        let url = self.url
        let imageURL = self.imageURL
        return Recipe(uuid: self.uuid, instructions: instructions, ingredientSections: ingredientSections, imageURL: imageURL, cookTime: cookTime, cuisine: cuisine, prepTime: prepTime, totalTime: totalTime, title: title, recipeDescription: recipeDescription, author: author, url: url, category: category, nutrients: nutrients, siteName: siteName, yields: yields)
    }
    
    public var hasImage: Bool {
        let noImage = self.image == nil && (self.imageURL == nil || self.imageURL?.absoluteString.isEmpty == true)
        return !noImage
    }
    
    public func canAddIngredient(to section: Int) -> Bool {
        let ingredientList = ingredientSections[section].ingredients
        if let last = ingredientList.last, !last.isEmpty {
            return true
        }
        
        if ingredientList.isEmpty {
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
