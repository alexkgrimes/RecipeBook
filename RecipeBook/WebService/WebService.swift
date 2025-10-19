//
//  WebService.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

final class WebService {
    
    static let endpointPrefix = "http://127.0.0.1:8000"
    
    // MARK: - Fetch Recipe
    
    static func fetchRecipes(for bookID: UUID? = nil) async -> [Recipe] {
        await withCheckedContinuation() { continuation in
            fetchRecipes(for: bookID) { recipes in
                continuation.resume(returning: recipes)
            }
        }
    }
    
    // TODO: add bookID, for now it's all one book ID
    private static func fetchRecipes(for bookID: UUID?, completion: @escaping ([Recipe]) -> Void) {
        // create get request
        let url = URL(string: endpointPrefix + "/recipes")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion([])
                return
            }
            
            // DEBUG
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Encoded JSON:")
//                print(jsonString)
//            }
            // DEBUG
            
            let decoder = JSONDecoder()
            do {
                let recipeModels = try decoder.decode([RecipeModel].self, from: data)
                let recipes = recipeModels.map { Recipe(from: $0) }
                completion(recipes)
            } catch {
                print("error: ", error)
                completion([])
            }
        }

        task.resume()
    }
    
    // MARK: - Add Recipe
    
    static func addRecipe(newRecipe: Recipe) async -> Void {
        await withCheckedContinuation() { continuation in
            addRecipe(newRecipe: newRecipe) {
                continuation.resume()
            }
        }
    }
    
    private static func addRecipe(newRecipe: Recipe, completion: @escaping () -> Void) {
        // prepare json data
        let recipeModel = RecipeModel(from: newRecipe)
        let jsonDict: [String: RecipeModel] = ["newRecipe": recipeModel]
        var jsonData: Data?
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            jsonData = try jsonEncoder.encode(jsonDict)
            // Convert the Data to a String for printing
//            if let jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("Encoded JSON new recipe:")
//                print(jsonString)
//            }
        } catch {
            completion()
            print("Error encoding model to JSON: \(error)")
        }
        
        // create post request
        let url = URL(string: endpointPrefix + "/update-recipe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion()
                return
            }
            completion()
        }

        task.resume()
    }
    
    // MARK: - Remove Recipe
    
    static func removeRecipe(uuid: UUID) async -> Void {
        await withCheckedContinuation() { continuation in
            removeRecipe(uuid: uuid) {
                continuation.resume()
            }
        }
    }
    
    private static func removeRecipe(uuid: UUID, completion: @escaping () -> Void) {
        // prepare json data
        let json: [String: Any] = ["uuid": uuid.uuidString]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: endpointPrefix + "/remove-recipe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion()
                return
            }
            completion()
        }

        task.resume()
    }
    
    // MARK: - Scrape Recipe
    
    static func parseRecipe(with url: String) async -> (Recipe, Bool) {
        await withCheckedContinuation { continuation in
            parseRecipe(with: url) { recipe, success in
                continuation.resume(returning: (recipe, success))
            }
        }
    }
    
    private static func parseRecipe(with url: String, completion: @escaping (Recipe, Bool) -> Void) {
        // prepare json data
        let json: [String: Any] = ["url": url]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: endpointPrefix + "/scrape-recipe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(Recipe.emptyRecipe(), false)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let scrapedRecipeModel = try decoder.decode(ScrapedRecipeModel.self, from: data)
                let recipe = Recipe(from: scrapedRecipeModel)
                completion(recipe, true)
            } catch {
                print("Error in JSON parsing for scrape recipe.")
                completion(Recipe.emptyRecipe(), false)
            }
        }

        task.resume()
    }
}
