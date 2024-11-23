//
//  WebService.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

final class WebService {
    
    static func fetchRecipe(with url: String) async -> Recipe {
        await withCheckedContinuation { continuation in
            fetchRecipe(with: url) { recipe in
                continuation.resume(returning: recipe)
            }
        }
    }
    
    private static func fetchRecipe(with url: String, completion: @escaping (Recipe) -> Void) {
        // prepare json data
        let json: [String: Any] = ["url": url]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "http://127.0.0.1:8000/recipe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(Recipe.emptyRecipe())
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let recipeModel = try decoder.decode(RecipeModel.self, from: data)
                let recipe = Recipe(from: recipeModel)
                completion(recipe)
            } catch {
                print("Error in JSON parsing.")
                completion(Recipe.emptyRecipe())
            }
        }

        task.resume()
    }
}
