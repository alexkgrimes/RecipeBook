//
//  HomeView.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject private var recipeViewModel: RecipeViewModel
    
    @State private var inputURL: Bool = false
    @State private var inputRecipe: Bool = false
    @State private var editRecipeBook: Bool = false

    @State private var searchText = ""
    @StateObject private var model: RecipeBookViewModel
    
    var filteredRecipes: [Recipe] {
        // Strip leading/trailing whitespace from `searchText`
        let spaceStrippedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        
        if spaceStrippedSearchText.isEmpty {
            return model.recipes
        }
        
        var labeledRecipes: [LabeledRecipe] = []
        
        let smartSearchMatcher = SmartSearchMatcher(searchString: spaceStrippedSearchText)
        for recipe in model.recipes {
            if smartSearchMatcher.matches(recipe.title) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 0))
                continue
            }
            
            if smartSearchMatcher.matches(recipe.cuisine) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 1))
                continue
            }
            
            if let category = recipe.category, smartSearchMatcher.matches(category) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 2))
                continue
            }
            
            if let recipeDescription = recipe.recipeDescription, smartSearchMatcher.matches(recipeDescription) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 2))
                continue
            }
            
            let ingredientsList = recipe.ingredients.joined(separator: " ")
            if smartSearchMatcher.matches(ingredientsList) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 3))
                continue
            }
            
            let instructionsList = recipe.instructions.joined(separator: " ")
            if smartSearchMatcher.matches(instructionsList) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 4))
                continue
            }
        }
        
        labeledRecipes.sort { (s1: LabeledRecipe, s2: LabeledRecipe) -> Bool in
            if s1.priority == s2.priority {
                return s1.recipe.timestamp > s2.recipe.timestamp
            }
            
            return s1.priority > s2.priority
        }
        
        return labeledRecipes.map { $0.recipe }
    }
    
    init(managedObjectContext: NSManagedObjectContext) {
        let model = RecipeBookViewModel(managedObjectContext: managedObjectContext)
        _model = StateObject(wrappedValue: model)
        
        recipeViewModel = RecipeViewModel(managedObjectContext: managedObjectContext)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRecipes) { recipe in
                    RecipeRowView(recipe: recipe, managedObjectContext: managedObjectContext)
                }
                .onDelete { (indexSet) in
                    for index in indexSet {
                        model.delete(recipe: filteredRecipes[index])
                    }
                }
            }
            .sheet(isPresented: $inputURL, onDismiss: {
                inputRecipe = true
            }) {
                URLInputView(recipeViewModel: recipeViewModel)
                    .presentationDetents([.fraction(0.3)])
                
            }
            .sheet(isPresented: $inputRecipe) {
                RecipeEditorView(editorMode: .new, recipeViewModel: recipeViewModel, saveRecipe: { recipe in
                    model.add(recipe: recipe)
                })
            }
            .sheet(isPresented: $editRecipeBook) {
                RecipeLibraryView(managedObjectContext: managedObjectContext, currentBookID: $model.currentBookID)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        editRecipeBook = true
                    } label: {
                        Image(systemName: "books.vertical.fill")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        inputURL = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search")
        .onChange(of: recipeViewModel.recipe) { _, _ in
            print("changed")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(modelContext: try! ModelContext(ModelContainer.init()))
//    }
//}
