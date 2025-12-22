//
//  Recipe.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

final class Recipe: Identifiable, Equatable, Copyable {
    
    var uuid: UUID
    var timestamp: Date = Date.now
    var instructionSections: [TitledList] = []
    var ingredientSections: [TitledList] = []
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
    var notes: String = ""
    var tags: [Tag] = []
    var videoURL: String = ""
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.uuid == rhs.uuid &&
            lhs.timestamp == rhs.timestamp &&
            lhs.instructionSections == rhs.instructionSections &&
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
            lhs.yields == rhs.yields &&
            lhs.notes == rhs.notes &&
            lhs.tags == rhs.tags &&
            lhs.videoURL == rhs.videoURL
    }
    
    init(uuid: UUID, instructionSections: [TitledList], ingredientSections: [TitledList], imageURL: URL?, image: Data?, cookTime: Int?, cuisine: String, prepTime: Int?, totalTime: Int?, title: String, recipeDescription: String, author: String?, url: URL?, category: String?, nutrients: [String: String]?, siteName: String?, yields: String, notes: String, tags: [Tag], videoURL: String) {
        self.uuid = uuid
        self.timestamp = .now
        self.instructionSections = instructionSections
        self.ingredientSections = ingredientSections
        self.imageURL = imageURL
        self.image = image
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
        self.notes = notes
        self.tags = tags
        self.videoURL = videoURL
    }
    
    init(from scrapedRecipeModel: ScrapedRecipeModel) {
        self.uuid = UUID()
        var instructions = [String]()
        scrapedRecipeModel.instructions?.enumerateLines { (line, stop) -> () in
            instructions.append(line)
        }
        self.instructionSections = [TitledList(sectionName: "", listItems: instructions)]
        self.timestamp = .now
        if let ingredients = scrapedRecipeModel.ingredients {
            self.ingredientSections = [TitledList(sectionName: "", listItems: ingredients)]
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
        self.instructionSections = recipeModel.instructionSections ?? []
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
        self.notes = recipeModel.notes ?? ""
        self.tags = recipeModel.tags ?? []
        self.videoURL = recipeModel.videoURL ?? ""
    }
    
    static func emptyRecipe() -> Recipe {
        return Recipe(uuid: UUID(), instructionSections: [], ingredientSections: [], imageURL: URL(string: ""), image: nil, cookTime: nil, cuisine: "", prepTime: nil, totalTime: nil, title: "", recipeDescription: "", author: "", url: URL(string: ""), category: "", nutrients: [:], siteName: "", yields: "", notes: "", tags: [], videoURL: "")
    }
    
    public func mutableCopy() -> Recipe {
        let ingredientSections = self.ingredientSections.map { $0.mutableCopy() }
        let instructionSections = self.instructionSections.map { $0.mutableCopy() }
        let nutrients = self.nutrients
        let url = self.url
        let imageURL = self.imageURL
        return Recipe(uuid: self.uuid, instructionSections: instructionSections, ingredientSections: ingredientSections, imageURL: imageURL, image: image, cookTime: cookTime, cuisine: cuisine, prepTime: prepTime, totalTime: totalTime, title: title, recipeDescription: recipeDescription, author: author, url: url, category: category, nutrients: nutrients, siteName: siteName, yields: yields, notes: notes, tags: tags, videoURL: videoURL)
    }
    
    public var hasImage: Bool {
        let noImage = self.image == nil && (self.imageURL == nil || self.imageURL?.absoluteString.isEmpty == true)
        return !noImage
    }
    
    public func canAddIngredient(to section: Int) -> Bool {
        let ingredientList = ingredientSections[section].listItems
        if let last = ingredientList.last, !last.isEmpty {
            return true
        }
        
        if ingredientList.isEmpty {
            return true
        }
        
        return false
    }
    
    public func canAddStep(to section: Int) -> Bool {
        let instructionList = instructionSections[section].listItems
        if let last = instructionList.last, !last.isEmpty {
            return true
        }
        
        if instructionList.isEmpty {
            return true
        }
        
        return false
    }
}
