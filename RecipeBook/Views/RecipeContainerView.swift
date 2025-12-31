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
    @EnvironmentObject var homeViewModel: HomeViewModel
    @ObservedObject var recipeViewModel: RecipeViewModel
    @State var viewMode: RecipeViewMode
    
    init(recipeViewModel: RecipeViewModel) {
        self.recipeViewModel = recipeViewModel
        self.viewMode = .view
    }
    
    var body: some View {
        ZStack {
            switch viewMode {
            case .view:
                RecipeDetailView(recipeViewModel: recipeViewModel, viewMode: $viewMode)
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewMode)
            case .edit:
                RecipeEditorView(editorMode: .update,
                                 recipeViewModel: RecipeViewModel(recipe: recipeViewModel.recipe.mutableCopy()),
                                 didSaveRecipe: { recipe in
                    if let recipe {
                        recipeViewModel.recipe = recipe
                    }
                    homeViewModel.loadData()
                },
                                 viewMode: $viewMode)
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewMode)
            }
        }
        .animation(.default, value: viewMode)
    }
}
