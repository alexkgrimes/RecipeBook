//
//  WebService.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

final class WebService {
    
    static var endpointPrefix: String? {
        let selectedHostOption = HostOption(rawValue: UserDefaults.standard.integer(forKey: "hostOption")) ?? .localhostDev
        let host = UserDefaults.standard.string(forKey: "hostname") ?? ""
        
        switch selectedHostOption {
        case .localhostDev:
            return "http://127.0.0.1:8000"
        case .localhostProd:
            return "http://0.0.0.0:8000"
        case .hostname, .ipAddress:
            if !host.isEmpty {
                return "http://\(host):8000"
            }
        case .url:
            if !host.isEmpty {
                return "http://\(host)"
            }
        }
        return nil
    }
    
    // MARK: - Fetch Recipe
    
    static func fetchRecipes(for bookID: UUID? = nil) async -> [Recipe]? {
        await withCheckedContinuation() { continuation in
            fetchRecipes(for: bookID) { recipes in
                continuation.resume(returning: recipes)
            }
        }
    }
    
    // TODO: add bookID, for now it's all one book ID
    private static func fetchRecipes(for bookID: UUID?, completion: @escaping ([Recipe]?) -> Void) {
        // create get request
        guard let endpointPrefix = endpointPrefix, let url = URL(string: endpointPrefix + "/recipes") else {
            print("endpointPrefix is nil, invalid URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                if let recipes = PersistenceManager.loadRecipesFromLocalFile() {
                    completion(recipes)
                    return
                }
                
                completion(nil)
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
                
                PersistenceManager.cacheRecipesToLocalFile(recipeModels: recipeModels)
            } catch {
                print("error: ", error)
                
                if let recipes = PersistenceManager.loadRecipesFromLocalFile() {
                    completion(recipes)
                    return
                }

                completion(nil)
                return
            }
        }

        task.resume()
    }
    
    // MARK: - Add Recipe
    
    static func addRecipe(newRecipe: Recipe) async -> Bool {
        await withCheckedContinuation() { continuation in
            addRecipe(newRecipe: newRecipe) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private static func addRecipe(newRecipe: Recipe, completion: @escaping (Bool) -> Void) {
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
            completion(false)
            print("Error encoding model to JSON: \(error)")
        }
        
        // create post request
        guard let endpointPrefix = endpointPrefix, let url = URL(string: endpointPrefix + "/update-recipe") else {
            print("endpointPrefix is nil, invalid URL")
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(false)
                return
            }
            completion(true)
        }

        task.resume()
    }
    
    // MARK: - Remove Recipe
    
    static func removeRecipe(uuid: UUID) async -> Bool {
        await withCheckedContinuation() { continuation in
            removeRecipe(uuid: uuid) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private static func removeRecipe(uuid: UUID, completion: @escaping (Bool) -> Void) {
        // prepare json data
        let json: [String: Any] = ["uuid": uuid.uuidString]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        guard let endpointPrefix = endpointPrefix, let url = URL(string: endpointPrefix + "/remove-recipe") else {
            print("endpointPrefix is nil, invalid URL")
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(false)
                return
            }
            completion(true)
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
        guard let endpointPrefix = endpointPrefix, let url = URL(string: endpointPrefix + "/scrape-recipe") else {
            print("endpointPrefix is nil, invalid URL")
            completion(Recipe.emptyRecipe(), false)
            return
        }
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
