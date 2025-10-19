//
//  HomeView.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var recipeViewModel = RecipeViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
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
            for ingredientSection in recipe.ingredientSections {
                let subList = ingredientSection.ingredients.joined(separator: " ")
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
        let columns = (horizontalSizeClass == .compact) ?
                   [GridItem(.flexible())] : // One column for iPhone
                   [GridItem(.flexible()), GridItem(.flexible())] // Two columns for iPad
        
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(filteredRecipes) { recipe in
                        rowView(recipe: recipe)
                    }
                    .onDelete { (indexSet) in
                        for index in indexSet {
                            model.delete(recipe: filteredRecipes[index])
                        }
                    }
                }
            }
            .background(Color(uiColor: UIColor.secondarySystemFill))
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search")
            .navigationTitle(model.currentBook?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $inputURL) {
                URLInputView(recipeViewModel: recipeViewModel) {
                    inputRecipe = true
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $inputRecipe) {
                RecipeEditorView(editorMode: .new, recipeViewModel: recipeViewModel, didSaveRecipe: { _ in
                    model.loadData()
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
    
    @ViewBuilder func rowView(recipe: Recipe) -> some View {
        RecipeRowView(recipe: recipe)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10.0)
                .fill(Color(uiColor: UIColor.secondarySystemGroupedBackground)))
            .padding([.leading, .trailing])
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
