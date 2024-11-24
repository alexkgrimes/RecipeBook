//
//  RecipeBookViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/23/24.
//

import Foundation
import SwiftUI
import CoreData

class RecipeBookViewModel: ObservableObject {
    var managedObjectContext: NSManagedObjectContext
    
    @Published var recipeBook: RecipeBook
    
    init(recipeBook: RecipeBook? = nil, managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.recipeBook = recipeBook ?? RecipeBook.defaultBook
    }
    
    func updateBook() {

        let fetchRequest = RecipeBookMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", recipeBook.uuid.uuidString)
        guard let recipeBookMO = try? managedObjectContext.fetch(fetchRequest).first else {
            return
        }
        recipeBookMO.setValue(recipeBook.name, forKeyPath: "name")

       do {
           try managedObjectContext.save()
       } catch let error as NSError  {
           print("Could not save \(error), \(error.userInfo)")
       }
   }
    
    func addBook() {
        let recipeBookMO = RecipeBookMO(context: managedObjectContext)
        
        recipeBookMO.setValue(recipeBook.uuid, forKeyPath: "uuid")
        recipeBookMO.setValue(recipeBook.name, forKeyPath: "name")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
