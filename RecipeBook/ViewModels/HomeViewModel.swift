//
//  HomeViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/27/24.
//

import Foundation
import SwiftUI
import CoreData

@Observable
class HomeViewModel: ObservableObject {
    var managedObjectContext: NSManagedObjectContext
    var recipes = [Recipe]()
    
    var currentBookID: UUID? = nil {
        didSet {
            print("currentBookID changed: \(oldValue?.uuidString) to \(currentBookID?.uuidString)")
            loadData()
        }
    }
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
 
    private func loadData() {
        do {
            Task {
                print("loadData()")
                
                guard let currentBookID = currentBookID else {
                    print("No current book ID")
                    return
                }
                
                let fetchRequest: NSFetchRequest<RecipeBookMO>
                fetchRequest = RecipeBookMO.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", currentBookID.uuidString)

                let recipeBookMOs = (try? self.managedObjectContext.fetch(fetchRequest)) ?? []
                
                guard let recipeMOs = recipeBookMOs.first?.recipes?.allObjects else {
                    print("No recipes for this book")
                    return
                }
                
                self.recipes = recipeMOs.compactMap {
                    guard let recipeMO = $0 as? RecipeMO else { return nil }
                    return Recipe(from: recipeMO)
                }
            }
        }
    }
    
    public func dataInitialization() {
        print("dataInitialization()")
        
        let fetchRequest: NSFetchRequest<RecipeBookMO>
        fetchRequest = RecipeBookMO.fetchRequest()
        let recipeBookMOs = (try? managedObjectContext.fetch(fetchRequest)) ?? []
        
        // Create a default book for which to store the recipes
        if recipeBookMOs.isEmpty {
            let defaultBook = RecipeBook.defaultBook
            let recipeBookMO = RecipeBookMO(context: managedObjectContext)
            
            recipeBookMO.setValue(defaultBook.uuid, forKeyPath: "uuid")
            recipeBookMO.setValue(defaultBook.name, forKeyPath: "name")
              
            do {
                try managedObjectContext.save()
                
                print("Setting to default book UUID")
                currentBookID = defaultBook.uuid
                return
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            // ALEX TODO: read the default that has the currentBookID, and see if it still exists
            // For now just used the first one
            
            print("Setting to first book UUID")
            currentBookID = recipeBookMOs.first?.uuid
            return
        }
        
        print("Something went wrong.")
        currentBookID = nil
    }
    
    func add(recipe: Recipe) {
        guard let currentBookID = currentBookID else {
            print("Something went wrong.")
            return
        }
        
        let fetchRequest: NSFetchRequest<RecipeBookMO>
        fetchRequest = RecipeBookMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", currentBookID.uuidString)
        let recipeBookMO = ((try? managedObjectContext.fetch(fetchRequest)) ?? []).first
        
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
        
        recipeMO.setValue(recipeBookMO, forKey: "book")
          
        do {
            try managedObjectContext.save()
            managedObjectContext.refresh(recipeBookMO!, mergeChanges: false)
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
