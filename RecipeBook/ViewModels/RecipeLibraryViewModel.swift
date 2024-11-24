//
//  RecipeLibraryViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/23/24.
//

import Foundation
import SwiftUI
import CoreData

@Observable
class RecipeLibraryViewModel: ObservableObject {
    
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
