//
//  RecipeDetailView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @State var showEditor: Bool = false
    
    init(recipeViewModel: RecipeViewModel) {
        self.recipeViewModel = recipeViewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    RecipeImage(recipeViewModel: recipeViewModel)
                        .frame(maxWidth: UIScreen.main.bounds.width - 32.0, maxHeight: 200)
                        .clipShape(.rect(cornerRadius: 25))
                    
                    Spacer(minLength: 16.0)
                    
                    HStack {
                        Spacer()
                        
                        if let totalTime = recipeViewModel.recipe.totalTime {
                            MetadataView(title: "Total Time", subtitle: "\(totalTime) mins")
                            Spacer()
                        }
                        
                        if let cookTime = recipeViewModel.recipe.cookTime {
                            MetadataView(title: "Cook Time", subtitle: "\(cookTime) mins")
                            Spacer()
                        }
                        
                        MetadataView(title: "Servings", subtitle: recipeViewModel.recipe.yields)
                        Spacer()
                    }
                    
                    Spacer(minLength: 16.0)
                    
                    Text("Ingredients")
                        .bold()
                    ForEach(recipeViewModel.recipe.ingredients.indices, id: \.self) { index in
                        Text("• \(recipeViewModel.recipe.ingredients[index])")
                    }
                    
                    Spacer(minLength: 16.0)
                    
                    Text("Instructions")
                        .bold()
                    ForEach(recipeViewModel.recipe.instructions.indices, id: \.self) { index in
                        Text("\(index + 1). \(recipeViewModel.recipe.instructions[index])")
                    }
                }
                .padding(.all)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showEditor = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                RecipeEditorView(editorMode: .update, recipeViewModel: recipeViewModel, saveRecipe: { recipe in
                    recipeViewModel.updateRecipe(recipe: recipe)
                })
            }
            .navigationTitle(recipeViewModel.recipe.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MetadataView: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }
}
