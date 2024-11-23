//
//  RecipeViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/9/24.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreData

@MainActor
class RecipeViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    var managedObjectContext: NSManagedObjectContext
    
    @Published var recipe: Recipe
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    init(recipe: Recipe? = nil, managedObjectContext: NSManagedObjectContext) {
        self.recipe = recipe ?? Recipe.emptyRecipe()
        self.managedObjectContext = managedObjectContext
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection = selection else {
            return
        }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                recipe.image = data
                objectWillChange.send()
            }
        }
    }

    public func addStepIfNeeded() {
        if recipe.canAddStep {
            recipe.instructions.append("")
            objectWillChange.send()
        }
    }
    
    public func addIngredientIfNeeded() {
        if recipe.canAddIngredient {
            recipe.ingredients.append("")
            objectWillChange.send()
        }
    }
    
    func updateRecipe(recipe: Recipe) {

        let fetchRequest = RecipeMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", recipe.uuid.uuidString)
        guard let recipeMO = try? managedObjectContext.fetch(fetchRequest).first else {
            return
        }
        
        recipeMO.setValue(recipe.uuid, forKeyPath: "uuid")
        recipeMO.setValue(recipe.timestamp, forKeyPath: "timestamp")
        recipeMO.setValue(recipe.instructions, forKeyPath: "instructions")
        recipeMO.setValue(recipe.ingredients, forKeyPath: "ingredients")
        recipeMO.setValue(recipe.imageURL, forKeyPath: "imageURL")
        recipeMO.setValue(recipe.image, forKeyPath: "image")
        recipeMO.setValue(recipe.cookTime, forKeyPath: "cookTime")
        recipeMO.setValue(recipe.cuisine, forKeyPath: "cuisine")
        recipeMO.setValue(recipe.prepTime, forKeyPath: "prepTime")
        recipeMO.setValue(recipe.totalTime, forKeyPath: "totalTime")
        recipeMO.setValue(recipe.title, forKeyPath: "title")
        recipeMO.setValue(recipe.recipeDescription, forKeyPath: "recipeDescription")
        recipeMO.setValue(recipe.author, forKeyPath: "author")
        recipeMO.setValue(recipe.url, forKeyPath: "url")
        recipeMO.setValue(recipe.category, forKeyPath: "category")
        recipeMO.setValue(recipe.nutrients, forKeyPath: "nutrients")
        recipeMO.setValue(recipe.ratings, forKeyPath: "ratings")
        recipeMO.setValue(recipe.siteName, forKeyPath: "siteName")
        recipeMO.setValue(recipe.yields, forKeyPath: "yields")

       do {
           try managedObjectContext.save()
       } catch let error as NSError  {
           print("Could not save \(error), \(error.userInfo)")
       }
   }
}
