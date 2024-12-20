//
//  RecipeEditorView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation
import SwiftUI
import PhotosUI

enum RecipeEditorMode {
    case new
    case update
}

struct RecipeEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    let editorMode: RecipeEditorMode
    var saveRecipe: ((Recipe) -> ())?
    
    init(editorMode: RecipeEditorMode, recipeViewModel: RecipeViewModel, saveRecipe: ((Recipe) -> ())? = nil) {
        self.editorMode = editorMode
        self.recipeViewModel = recipeViewModel
        self.saveRecipe = saveRecipe
    }
    
    var body: some View {
        NavigationStack {
            manualEntryForm
                .navigationTitle(editorMode == .new ? "New Recipe" : "Update Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            editorMode == .new ? Text("Cancel") : Text("Close")
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    var manualEntryForm: some View {
        Form {
            Section {
                RecipeImage(recipeViewModel: recipeViewModel)
                    .listRowInsets(EdgeInsets())
                PhotosPicker(imageButtonString, selection: $recipeViewModel.imageSelection, matching: .images)
            }
        
            Section("Title") {
                TextField("Title", text: $recipeViewModel.recipe.title)
            }
            
            Section("Yields") {
                TextField("Servings", text: $recipeViewModel.recipe.yields)
            }
            
            Section("Prep Time") {
                TextField("", value: $recipeViewModel.recipe.prepTime, format: .number, prompt: Text("Prep Time (mins)"))
                    .keyboardType(UIKeyboardType.decimalPad)
            }
            
            Section("Cook Time") {
                TextField("", value: $recipeViewModel.recipe.cookTime, format: .number, prompt: Text("Cook Time (mins)"))
                    .keyboardType(UIKeyboardType.decimalPad)
            }
            
            Section("Total Time") {
                TextField("", value: $recipeViewModel.recipe.totalTime, format: .number, prompt: Text("Total Time (mins)"))
                    .keyboardType(UIKeyboardType.decimalPad)
            }
            
            Section("Ingredients") {
                ForEach($recipeViewModel.recipe.ingredients.indices, id: \.self) { index in
                    TextField("Enter ingredient", text: $recipeViewModel.recipe.ingredients[index], axis: .vertical)
                }
                
                Button {
                    recipeViewModel.addIngredientIfNeeded()
                } label: {
                    Text("Add Ingredient")
                }
            }
            
            Section("Instructions") {
                ForEach($recipeViewModel.recipe.instructions.indices, id: \.self) { index in
                    TextField("Enter step", text: $recipeViewModel.recipe.instructions[index], axis: .vertical)
                }
                
                Button {
                    recipeViewModel.addStepIfNeeded()
                } label: {
                    Text("Add Step")
                }
            }
            
            Button {
                recipeViewModel.recipe.ingredients = recipeViewModel.recipe.ingredients.filter { !$0.isEmpty }
                recipeViewModel.recipe.instructions = recipeViewModel.recipe.instructions.filter { !$0.isEmpty }
                saveRecipe?(recipeViewModel.recipe)
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Save Recipe")
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
    
    var imageButtonString: String {
        return recipeViewModel.recipe.hasImage ? "Edit Image" : "Add Image"
    }
}

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
