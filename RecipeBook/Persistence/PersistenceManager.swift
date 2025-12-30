//
//  Persistence.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/26/25.
//

import Foundation

public class PersistenceManager {
    static let recipeFilename = "recipes.txt"
    static let tagsFilename = "tags.txt"
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func cacheRecipesToLocalFile(recipeModels: [RecipeModel]) {
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(PersistenceManager.recipeFilename)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(recipeModels)
            // jsonData is now a Data object containing the JSON representation
            
            try jsonData.write(to: fileURL)
            print("Successfully wrote to file: \(fileURL.lastPathComponent)")
        } catch {
            print("Error encoding objects to JSON: \(error)")
        }
    }
    
    static func loadRecipesFromLocalFile() -> [Recipe]? {
        do {
            let documentsDirectory = getDocumentsDirectory()
            let fileURL = documentsDirectory.appendingPathComponent(PersistenceManager.recipeFilename)
            let savedData = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            do {
                let recipeModels = try decoder.decode([RecipeModel].self, from: savedData)
                print("Successfully read from file")
                
                return recipeModels.map { Recipe(from: $0) }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                return nil
            }
        } catch {
            print("Error reading from file: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func cacheTagsToLocalFile(tags: [Tag]) {
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(PersistenceManager.tagsFilename)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(tags)
            // jsonData is now a Data object containing the JSON representation
            
            try jsonData.write(to: fileURL)
            print("Successfully wrote to file: \(fileURL.lastPathComponent)")
        } catch {
            print("Error encoding objects to JSON: \(error)")
        }
    }
    
    static func loadTagsFromLocalFile() -> [Tag]? {
        do {
            let documentsDirectory = getDocumentsDirectory()
            let fileURL = documentsDirectory.appendingPathComponent(PersistenceManager.tagsFilename)
            let savedData = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            do {
                let tags = try decoder.decode([Tag].self, from: savedData)
                print("Successfully read from file")
                
                return tags
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                return nil
            }
        } catch {
            print("Error reading from file: \(error.localizedDescription)")
            return nil
        }
    }
}

