//
//  RecipeDetailView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss
    @State var showEditor: Bool = false
    @State var cookModeOn: Bool = false
    
    init(recipeViewModel: RecipeViewModel) {
        self.recipeViewModel = recipeViewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .top, spacing: 8.0) {
                        RecipeImage(recipeViewModel: recipeViewModel)
                            .frame(width: 120, height: 120)
                            .clipShape(.rect(cornerRadius: 10))

                        VStack(alignment: .leading) {
                            Text(recipeViewModel.recipe.title)
                                .foregroundStyle(.primary)
                                .font(.title)
                                .bold()
                        }
                    }
                    Spacer(minLength: 16.0)
                    
                    HStack(alignment: .center, spacing: 32.0) {
                        ServingsView(yield: recipeViewModel.recipe.yields)
                        
                        if let totalTime = recipeViewModel.recipe.totalTime {
                            TimeView(totalTime: totalTime, prepTime: recipeViewModel.recipe.prepTime, cookTime: recipeViewModel.recipe.cookTime)
                        }
                        Spacer()
                    }
                    
                    Toggle("Cook Mode", isOn: $cookModeOn)
                        .foregroundStyle(.secondary)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1.0)
                        .foregroundStyle(.tertiary)
                    
                    Spacer(minLength: 16.0)

                    
                    Text("Ingredients")
                        .font(.title2)
                        .bold()
                    
                    Spacer(minLength: 8.0)
                    
                    ForEach(recipeViewModel.recipe.ingredients.indices, id: \.self) { index in
                        Text("• \(recipeViewModel.recipe.ingredients[index])")
                        Spacer(minLength: 4.0)
                    }
                    
                    Spacer(minLength: 16.0)
                    
                    Text("Instructions")
                        .font(.title2)
                        .bold()
                    
                    Spacer(minLength: 8.0)
                    
                    ForEach(recipeViewModel.recipe.instructions.indices, id: \.self) { index in
                        
                        HStack(alignment: .top, spacing: 8.0) {
                            Text("\(index + 1)")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color.accentColor)
                            
                            Text("\(recipeViewModel.recipe.instructions[index])")
                        }
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
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                RecipeEditorView(editorMode: .update, recipeViewModel: recipeViewModel, saveRecipe: { recipe in
                    recipeViewModel.updateRecipe(recipe: recipe)
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: cookModeOn) {
                UIApplication.shared.isIdleTimerDisabled = cookModeOn
            }
            .onDisappear() {
                cookModeOn = false
            }
        }
    }
}

struct TimeView: View {
    @State var showAllTimes: Bool = false
    let totalTime: Int
    let prepTime: Int?
    let cookTime: Int?
    
    var hasOtherTimes: Bool {
        prepTime != nil || cookTime != nil
    }
    
    var body: some View {
        Button {
            showAllTimes = true
        } label: {
            HStack(alignment: .center, spacing: 8.0) {
                Image(systemName: "clock")
                Text("\(totalTime) mins")
            }
            .foregroundStyle(hasOtherTimes ? Color.accentColor : .secondary)
        }
        .popover(isPresented: $showAllTimes) {
            VStack {
                Text("Total time: \(totalTime) mins")
                
                if let prepTime = prepTime {
                    Text("Prep time: \(prepTime) mins")
                }
                
                if let cookTime = cookTime {
                    Text("Cook time: \(cookTime) mins")
                }
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct ServingsView: View {
    let yield: String
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8.0) {
            Image(systemName: "minus")
            Text(yield)
            Image(systemName: "plus")
        }
        .foregroundStyle(.secondary)
        .padding()
        .background(Capsule()
            .stroke(lineWidth: 1.0)
            .foregroundStyle(.secondary))
    }
}
