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
    var didSaveRecipe: ((Recipe) -> ())?
    
    init(editorMode: RecipeEditorMode, recipeViewModel: RecipeViewModel, didSaveRecipe: ((Recipe) -> ())? = nil) {
        self.editorMode = editorMode
        self.recipeViewModel = recipeViewModel
        self.didSaveRecipe = didSaveRecipe
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                manualEntryForm(proxy: proxy)
                    .navigationTitle(editorMode == .new ? "New Recipe" : "Update Recipe")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        if editorMode == .update {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    Task {
                                        await recipeViewModel.updateRecipe()
                                        didSaveRecipe?(recipeViewModel.recipe)
                                        dismiss()
                                    }
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    func manualEntryForm(proxy: ScrollViewProxy) -> some View {
        Form {
            Section {
                RecipeImage(recipeViewModel: recipeViewModel)
                    .listRowInsets(EdgeInsets())
                PhotosPicker(imageButtonString, selection: $recipeViewModel.imageSelection, matching: .images)
            }
        
            Section("Title") {
                TextField("Title", text: $recipeViewModel.recipe.title)
            }
            
            Section("Description") {
                TextField("Description", text: $recipeViewModel.recipe.recipeDescription, axis: .vertical)
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
                ingredientsEditorView(proxy: proxy)
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
            
            if editorMode == .new {
                Button {
                    Task {
                        await recipeViewModel.addRecipe()
                        didSaveRecipe?(recipeViewModel.recipe)
                        dismiss()
                    }
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
    }
    
    var imageButtonString: String {
        return recipeViewModel.recipe.hasImage ? "Edit Image" : "Add Image"
    }
    
    @ViewBuilder func ingredientsEditorView(proxy: ScrollViewProxy) -> some View {
        Button {
            // TODO: scroll to new section
            recipeViewModel.addFlattenedIngredientSection()
            proxy.scrollTo(recipeViewModel.flattenedIngredients.count - 1)
        } label: {
            Text("Add Section")
                .foregroundStyle(Color.accentColor)
                .listStyle(.plain)
        }
        ForEach(recipeViewModel.flattenedIngredients.indices, id: \.self) { index in
            if index != 0 && recipeViewModel.flattenedIngredients[index].type == .title {
                TextField("Enter section title", text: $recipeViewModel.flattenedIngredients[index].text)
                    .id(index)
                    .listStyle(.plain)
                    .textFieldStyle(.plain)
                    .bold()
            } else if recipeViewModel.flattenedIngredients[index].type == .ingredient {
                TextField("Enter ingredient", text: $recipeViewModel.flattenedIngredients[index].text, axis: .vertical)
                    .id(index)
            } else if recipeViewModel.flattenedIngredients[index].type == .addIngredientButton {
                Button {
                    recipeViewModel.addFlattenedIngredientIfNeeded(at: index)
                } label: {
                    Text("Add Ingredient")
                        .listStyle(.plain)
                }
                .id(index)
                .deleteDisabled(true)
                .moveDisabled(true)

            }
        }
        .onDelete { offsets in
            for i in offsets {
                recipeViewModel.flattenedIngredients.remove(at: i)
            }
        }
        .onMove { indexSet, destination in
            // TODO: when moving a section header, need to move the add ingredient button too
            recipeViewModel.flattenedIngredients.move(fromOffsets: indexSet, toOffset: destination)
        }
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
