//
//  RecipeBooksView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/3/24.
//

import SwiftUI
import CoreData

struct RecipeBooksView: View {
    
    @StateObject private var model: RecipeBookListViewModel
    
    init(managedObjectContext: NSManagedObjectContext) {
        let model = RecipeBookListViewModel(managedObjectContext: managedObjectContext)
        _model = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        List {
            ForEach(model.recipeBooks) { recipeBook in
                VStack {
                    Text(recipeBook.name)
                }
            }
        }
    }
}
