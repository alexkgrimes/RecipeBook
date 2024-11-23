//
//  RecipeBookViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/27/24.
//

import Foundation
import SwiftUI
import CoreData

@Observable
class RecipeBookListViewModel: ObservableObject {
    var managedObjectContext: NSManagedObjectContext
    
    var recipeBooks = [RecipeBook]()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        loadData()
    }
    
    private func loadData() {
        do {
            let fetchRequest: NSFetchRequest<RecipeBookMO>
            fetchRequest = RecipeBookMO.fetchRequest()

            let recipeBookMOs = (try? managedObjectContext.fetch(fetchRequest)) ?? []
            self.recipeBooks = recipeBookMOs.map { RecipeBook(from: $0) }
        }
    }
}

@Observable
class RecipeBookViewModel: ObservableObject {
    var managedObjectContext: NSManagedObjectContext
    
    var recipes = [Recipe]()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        loadData()
    }
 
    private func loadData() {
        do {
            let fetchRequest: NSFetchRequest<RecipeMO>
            fetchRequest = RecipeMO.fetchRequest()

            let recipeMOs = (try? managedObjectContext.fetch(fetchRequest)) ?? []
            self.recipes = recipeMOs.map { Recipe(from: $0) }
        }
    }
    
    func add(recipe: Recipe) {
        let recipeMO = RecipeMO(context: managedObjectContext)
        
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
            loadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func delete(recipe: Recipe) {
        
        let fetchRequest = RecipeMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", recipe.uuid.uuidString)

        guard let recipeMO = try? managedObjectContext.fetch(fetchRequest).first else {
            return
        }
        
        managedObjectContext.delete(recipeMO)
        do {
            try managedObjectContext.save()
            loadData()
        } catch{
            print(error)
        }
    }
}
