//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI

class DeeplinkEnvironment {
    
}

@main
struct RecipeBookApp: App {
    @ObservedObject private var recipeViewModel = RecipeViewModel()
    @State public var inputURL: Bool = false
    @State  public var inputRecipe: Bool = false
    
    var body: some Scene {
        WindowGroup {
            HomeView(recipeViewModel: recipeViewModel, inputURL: $inputURL, inputRecipe: $inputRecipe)
                .onOpenURL { url in
                    print("Received deep link: \(url)")
                    inputURL = false
                    inputRecipe = false
                    recipeViewModel.recipe = Recipe.emptyRecipe()
                    // Add logic here to navigate to a specific view based on the URL
                    
                    let urlString = url.absoluteString

                    if let urlComponents = URLComponents(string: urlString), let queryItems = urlComponents.queryItems {
                        for item in queryItems {
                            print("Parameter name: \(item.name), value: \(item.value ?? "N/A")")
                        }

                        // Access a specific query item value
                        if let recipeURL = queryItems.first(where: { $0.name == "url" })?.value {
                            print("The URL is: \(recipeURL)")
                            Task {
                                let (recipe, success) = await WebService.parseRecipe(with: recipeURL)
                                recipeViewModel.recipe = recipe
                                inputRecipe = true
                            }
                        }
                    }
                }
        }
    }
}
