//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case newRecipe
}

@main
struct RecipeBookApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var newRecipeViewModel = RecipeViewModel()
    @StateObject private var tagsViewModel = TagsViewModel()

    @State public var inputURL: Bool = false
    @State private var parseAlert: Bool = false
    
    @State private var path: [NavigationDestination] = []
    
    var body: some Scene {
        WindowGroup {
            HomeView(inputURL: $inputURL, path: $path)
                .onOpenURL { url in
                    print("Received deep link: \(url)")
                    inputURL = false
                    path = []
                    newRecipeViewModel.recipe = Recipe.emptyRecipe()
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
                                guard success else {
                                    parseAlert = true
                                    return
                                }
                                newRecipeViewModel.recipe = recipe
                                path.append(.newRecipe)
                            }
                        }
                    }
                }
                .alert("Parse Failure", isPresented: $parseAlert) {
                    Button("Enter Manually") {
                        path.append(.newRecipe)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Failed to parse recipe from URL.")
                }
                .environmentObject(homeViewModel)
                .environmentObject(newRecipeViewModel)
                .environmentObject(tagsViewModel)
        }
    }
}
