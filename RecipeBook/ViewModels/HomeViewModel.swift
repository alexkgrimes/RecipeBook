//
//  HomeViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/27/24.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recipes = [Recipe]()
    @Published var showErrorAlert: Bool = false
    
    var currentBook: RecipeBook? = nil {
        didSet {
            print("currentBook changed: \(String(describing: oldValue?.uuid.uuidString)) to \(String(describing: currentBook?.uuid.uuidString))")
            loadData()
        }
    }
 
    func loadData() {
        Task {
            print("loadData()")
            let recipes = await WebService.fetchRecipes()
            guard let recipes else {
                self.recipes = []
                showErrorAlert = true
                return
            }
            self.recipes = recipes
        }
    }
    
    public func dataInitialization() {
        print("dataInitialization()")
        // This is where we could store locally a "currentBook" for this device
        // Read that value, and use it to trigger the recipe load
        // For now though, we only have one book and it doesn't matter
        currentBook = nil
    }
    
    func delete(recipe: Recipe) {
        Task {
            print("deleteRecipe")
            await WebService.removeRecipe(uuid: recipe.uuid)
            loadData()
        }
    }
}
