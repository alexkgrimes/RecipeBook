//
//  RecipeContainerView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/1/25.
//

import SwiftUI

enum RecipeViewMode {
    case view
    case edit
}

struct RecipeContainerView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @State var viewMode: RecipeViewMode
    
    init(recipeViewModel: RecipeViewModel) {
        self.recipeViewModel = recipeViewModel
        self.viewMode = .view
    }
    
    var body: some View {
        switch viewMode {
        case .view:
            RecipeDetailView(recipeViewModel: recipeViewModel, viewMode: $viewMode)
                .transition(.opacity)
        case .edit:
            RecipeEditorView(editorMode: .update,
                             recipeViewModel: RecipeViewModel(recipe: recipeViewModel.recipe.mutableCopy()), viewMode: $viewMode)
                .navigationBarBackButtonHidden()
                .transition(.opacity)
        }
    }
}
