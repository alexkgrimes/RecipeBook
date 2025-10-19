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
    
    var currentBook: RecipeBook? = nil {
        didSet {
            print("currentBook changed: \(String(describing: oldValue?.uuid.uuidString)) to \(String(describing: currentBook?.uuid.uuidString))")
            loadData()
        }
    }
 
    func loadData() {
        Task {
            print("loadData()")
            self.recipes = await WebService.fetchRecipes()
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
