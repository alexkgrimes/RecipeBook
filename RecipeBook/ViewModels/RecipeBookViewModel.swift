//
//  RecipeBookViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/23/24.
//

import Foundation
import SwiftUI

@MainActor
class RecipeBookViewModel: ObservableObject {
    @Published var recipeBook: RecipeBook
    
    init(recipeBook: RecipeBook? = nil) {
        self.recipeBook = recipeBook ?? RecipeBook.defaultBook
    }
    
    func updateBook() {
        // TODO: when we have more than one book
   }
    
    func addBook() {
        // TODO: when we have more than one book
    }
}
