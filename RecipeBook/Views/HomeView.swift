//
//  HomeView.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var recipeViewModel = RecipeViewModel()
    
    @State private var inputURL: Bool = false
    @State private var inputRecipe: Bool = false
    @State private var editRecipeBook: Bool = false

    @State private var searchText = ""
    @StateObject private var model = HomeViewModel()
    
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
            
            if !recipe.recipeDescription.isEmpty, smartSearchMatcher.matches(recipe.recipeDescription) {
                labeledRecipes.append(LabeledRecipe(recipe: recipe, priority: 2))
                continue
            }
            
            var completeIngredientsList = ""
            for (_, ingredientsList) in recipe.ingredients {
                let subList = ingredientsList.joined(separator: " ")
                completeIngredientsList.append(subList)
            }
            if smartSearchMatcher.matches(completeIngredientsList) {
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

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecipes) { recipe in
                    RecipeRowView(recipe: recipe)
                }
                .onDelete { (indexSet) in
                    for index in indexSet {
                        model.delete(recipe: filteredRecipes[index])
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search")
            .navigationTitle(model.currentBook?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
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
                RecipeLibraryView(currentBook: $model.currentBook)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        editRecipeBook = true
                    } label: {
                        Image(systemName: "books.vertical.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        inputURL = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            model.dataInitialization()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
