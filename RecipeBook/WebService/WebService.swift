//
//  WebService.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

final class WebService {
    
    // MARK: - Private
    
    private static var endpointPrefix: String? {
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
    
    private static func getRequest(with path: String) -> URLRequest? {
        // create get request
        guard let endpointPrefix = endpointPrefix, let url = URL(string: endpointPrefix + "/\(path)") else {
            print("endpointPrefix is nil, invalid URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private static func postRequest<T: Encodable>(path: String, with parameters: [String: T]) -> URLRequest? {
        var jsonData: Data?
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            jsonData = try jsonEncoder.encode(parameters)
        } catch {
            print("Error encoding model to JSON: \(error)")
            return nil
        }
        
        // create post request
        guard let endpointPrefix = endpointPrefix, let url = URL(string: endpointPrefix + "/\(path)") else {
            print("endpointPrefix is nil, invalid URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        return request
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
        guard let request = getRequest(with: "recipes") else {
            completion(nil)
            return
        }
        
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
//            // DEBUG
            
            let decoder = JSONDecoder()
            do {
                let recipeModels = try decoder.decode([RecipeModel].self, from: data)
                let recipes = recipeModels.map { Recipe(from: $0) }
                completion(recipes)
                
                if !recipes.isEmpty {
                    PersistenceManager.cacheRecipesToLocalFile(recipeModels: recipeModels)
                }
            } catch {
                print("fetch recipes error: ", error)
                
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
        let recipeModel = RecipeModel(from: newRecipe)
        let jsonDict: [String: RecipeModel] = ["newRecipe": recipeModel]
        guard let request = postRequest(path: "update-recipe", with: jsonDict) else {
            completion(false)
            return
        }
        
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
        let jsonDict: [String: String] = ["uuid": uuid.uuidString]
        guard let request = postRequest(path: "remove-recipe", with: jsonDict) else {
            completion(false)
            return
        }
        
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
        let jsonDict: [String: String] = ["url": url]
        guard let request = postRequest(path: "scrape-recipe", with: jsonDict) else {
            completion(Recipe.emptyRecipe(), false)
            return
        }

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
    
    // MARK: Tags
    
    static func fetchTags() async -> [Tag] {
        await withCheckedContinuation { continuation in
            fetchTags() { tags in
                continuation.resume(returning: tags)
            }
        }
    }
    
    private static func fetchTags(completion: @escaping ([Tag]) -> Void) {
        guard let request = getRequest(with: "tags") else {
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")

                if let tags = PersistenceManager.loadTagsFromLocalFile() {
                    completion(tags)
                    return
                }
                
                completion([])
                return
            }
            
            // DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Encoded JSON:")
                print(jsonString)
            }
            // DEBUG
            
            let decoder = JSONDecoder()
            do {
                let tags = try decoder.decode([Tag].self, from: data)
                completion(tags)
                
                PersistenceManager.cacheTagsToLocalFile(tags: tags)
            } catch {
                print("fetch tags error: ", error)
                if let tags = PersistenceManager.loadTagsFromLocalFile() {
                    completion(tags)
                    return
                }

                completion([])
                return
            }
        }

        task.resume()
    }
    
    // MARK: - Add Tag
    
    static func addTag(newTag: Tag) async -> Bool {
        await withCheckedContinuation() { continuation in
            addTag(newTag: newTag) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private static func addTag(newTag: Tag, completion: @escaping (Bool) -> Void) {
        let jsonDict: [String: Tag] = ["newTag": newTag]
        guard let request = postRequest(path: "update-tag", with: jsonDict) else {
            completion(false)
            return
        }
        
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
    
    // MARK: - Delete tag
    
    static func removeTag(uuid: UUID) async -> Bool {
        await withCheckedContinuation() { continuation in
            removeTag(uuid: uuid) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private static func removeTag(uuid: UUID, completion: @escaping (Bool) -> Void) {
        guard let request = postRequest(path: "remove-tag", with: ["uuid": uuid.uuidString]) else {
            completion(false)
            return
        }
        
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
}
