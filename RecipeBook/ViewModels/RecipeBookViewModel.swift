//
//  RecipeBookViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/27/24.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class RecipeBookViewModel: ObservableObject {
    var modelContext: ModelContext
    
    var recipes = [Recipe]()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    private func loadData() {
        do {
            let descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            let recipes = try? modelContext.fetch(descriptor)
            self.recipes = recipes ?? []
        }
    }
    
    func add(recipe: Recipe) {
        modelContext.insert(recipe)
        loadData()
    }
    
    func delete(recipe: Recipe) {
        modelContext.delete(recipe)
        try? modelContext.save()
        loadData()
    }
    
    func deleteRecipe(at indexSet: IndexSet) {
        for index in indexSet{
            modelContext.delete(recipes[index])
        }
        try? modelContext.save()
        loadData()
    }
}
