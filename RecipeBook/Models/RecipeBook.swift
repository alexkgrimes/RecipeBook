//
//  RecipeBook.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/31/24.
//

import Foundation

final class RecipeBook: Identifiable {
    var uuid: UUID
    var name: String = ""
    
    init(uuid: UUID, name: String) {
        self.uuid = uuid
        self.name = name
    }
    
    init(from recipeBookMO: RecipeBookMO) {
        self.uuid = recipeBookMO.uuid ?? UUID()
        self.name = recipeBookMO.name ?? ""
    }
    
    static var defaultBook: RecipeBook {
        return RecipeBook(uuid: UUID(), name: "")
    }
}
