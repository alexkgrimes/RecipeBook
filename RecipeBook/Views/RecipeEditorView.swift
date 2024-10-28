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
    @StateObject var photoPickerViewModel: PhotoPickerViewModel
    @Binding var recipe: Recipe
    
    let editorMode: RecipeEditorMode
    var saveRecipe: ((Recipe) -> ())?
    
    init(editorMode: RecipeEditorMode, recipe: Binding<Recipe>, saveRecipe: ((Recipe) -> ())? = nil) {
        self.editorMode = editorMode
        self._recipe = recipe
        self._photoPickerViewModel = StateObject(wrappedValue: PhotoPickerViewModel(recipe: recipe))
        self.saveRecipe = saveRecipe
    }
    
    var body: some View {
        NavigationStack {
            manualEntryForm
                .navigationTitle(editorMode == .new ? "New Recipe" : "Update Recipe")
        }
    }
    
    @ViewBuilder
    var manualEntryForm: some View {
        Form {
            Section {
                RecipeImage(recipe: $recipe)
                    .listRowInsets(EdgeInsets())
                PhotosPicker(imageButtonString, selection: $photoPickerViewModel.imageSelection, matching: .images)
            }
        
            Section("Title") {
                TextField("Title", text: $recipe.title)
            }
            
            Section("Yields") {
                TextField("Servings", text: $recipe.yields)
            }
            
            Section("Prep Time") {
                TextField("", value: $recipe.prepTime, format: .number, prompt: Text("Prep Time (mins)"))
                    .keyboardType(UIKeyboardType.decimalPad)
            }
            
            Section("Cook Time") {
                TextField("", value: $recipe.cookTime, format: .number, prompt: Text("Cook Time (mins)"))
                    .keyboardType(UIKeyboardType.decimalPad)
            }
            
            Section("Total Time") {
                TextField("", value: $recipe.totalTime, format: .number, prompt: Text("Total Time (mins)"))
                    .keyboardType(UIKeyboardType.decimalPad)
            }
            
            Section("Ingredients") {
                ForEach($recipe.ingredients.indices, id: \.self) { index in
                    TextField("Enter ingredient", text: $recipe.ingredients[index], axis: .vertical)
                }
                
                Button {
                    recipe.addIngredientIfNeeded()
                } label: {
                    Text("Add Ingredient")
                }
            }
            
            Section("Instructions") {
                ForEach($recipe.instructions.indices, id: \.self) { index in
                    TextField("Enter step", text: $recipe.instructions[index], axis: .vertical)
                }
                
                Button {
                    recipe.addStepIfNeeded()
                } label: {
                    Text("Add Step")
                }
            }
            
            if editorMode == .new {
                Button {
                    recipe.ingredients = recipe.ingredients.filter { !$0.isEmpty }
                    recipe.instructions = recipe.instructions.filter { !$0.isEmpty }
                    saveRecipe?(recipe)
                    dismiss()
                } label: {
                    Text("Save Recipe")
                }
            }
        }
    }
    
    var imageButtonString: String {
        return recipe.hasImage ? "Edit Image" : "Add Image"
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
