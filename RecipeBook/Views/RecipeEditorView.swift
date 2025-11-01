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
    @Binding var viewMode: RecipeViewMode
    
    let editorMode: RecipeEditorMode
    var didSaveRecipe: ((Recipe) -> ())?
    
    init(editorMode: RecipeEditorMode, recipeViewModel: RecipeViewModel, didSaveRecipe: ((Recipe) -> ())? = nil, viewMode: Binding<RecipeViewMode>) {
        self.editorMode = editorMode
        self.recipeViewModel = recipeViewModel
        self.didSaveRecipe = didSaveRecipe
        _viewMode = viewMode
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
                                dismissView()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        if editorMode == .update {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    Task {
                                        let success = await recipeViewModel.updateRecipe()
                                        if success {
                                            didSaveRecipe?(recipeViewModel.recipe)
                                            dismissView()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
            }
        }
        .alert(isPresented: $recipeViewModel.showErrorAlert) {
            Alert(title: Text("Network Error"),
                  message: Text("Failed to save recipes."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func dismissView() {
        if editorMode == .update {
            viewMode = .view
        } else {
            dismiss()
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
                instructionEditorView()
            }
            
            if editorMode == .new {
                Button {
                    Task {
                        let success = await recipeViewModel.addRecipe()
                        if success {
                            didSaveRecipe?(recipeViewModel.recipe)
                            dismissView()
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Add Recipe")
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
    
    @ViewBuilder func instructionEditorView() -> some View {
        Button {
            // TODO: scroll to new section
            recipeViewModel.addFlattenedInstructionSection()
        } label: {
            Text("Add Section")
                .foregroundStyle(Color.accentColor)
                .listStyle(.plain)
        }
        ForEach(recipeViewModel.flattenedInstructions.indices, id: \.self) { index in
            if index != 0 && recipeViewModel.flattenedInstructions[index].type == .title {
                TextField("Enter section title", text: $recipeViewModel.flattenedInstructions[index].text)
                    .listStyle(.plain)
                    .textFieldStyle(.plain)
                    .bold()
            } else if recipeViewModel.flattenedInstructions[index].type == .listItem {
                TextField("Enter step", text: $recipeViewModel.flattenedInstructions[index].text, axis: .vertical)
                    .id(index)
            } else if recipeViewModel.flattenedInstructions[index].type == .addButton {
                Button {
                    recipeViewModel.addFlattenedStepIfNeeded(at: index)
                } label: {
                    Text("Add Step")
                        .listStyle(.plain)
                }
                .deleteDisabled(true)
                .moveDisabled(true)
            }
        }
        .onDelete { offsets in
            for i in offsets {
                recipeViewModel.flattenedInstructions.remove(at: i)
            }
        }
        .onMove { indexSet, destination in
            if let fromIndex = indexSet.first {
                // When moving a section header, need to move the add ingredient button too
                if recipeViewModel.flattenedInstructions[fromIndex].type == .title
                    && recipeViewModel.flattenedInstructions[safe: fromIndex - 1]?.type == .addButton {
                    recipeViewModel.flattenedInstructions.move(fromOffsets: IndexSet([fromIndex - 1, fromIndex]), toOffset: destination)
                    return
                }
            }
            
            recipeViewModel.flattenedInstructions.move(fromOffsets: indexSet, toOffset: destination)
        }
    }
    
    @ViewBuilder func ingredientsEditorView(proxy: ScrollViewProxy) -> some View {
        Button {
            // TODO: scroll to new section
            recipeViewModel.addFlattenedIngredientSection()
        } label: {
            Text("Add Section")
                .foregroundStyle(Color.accentColor)
                .listStyle(.plain)
        }
        ForEach(recipeViewModel.flattenedIngredients.indices, id: \.self) { index in
            if index != 0 && recipeViewModel.flattenedIngredients[index].type == .title {
                TextField("Enter section title", text: $recipeViewModel.flattenedIngredients[index].text)
                    .listStyle(.plain)
                    .textFieldStyle(.plain)
                    .bold()
            } else if recipeViewModel.flattenedIngredients[index].type == .listItem {
                TextField("Enter ingredient", text: $recipeViewModel.flattenedIngredients[index].text, axis: .vertical)
                    .id(index)
            } else if recipeViewModel.flattenedIngredients[index].type == .addButton {
                Button {
                    recipeViewModel.addFlattenedIngredientIfNeeded(at: index)
                } label: {
                    Text("Add Ingredient")
                        .listStyle(.plain)
                }
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
            if let fromIndex = indexSet.first {
                // When moving a section header, need to move the add ingredient button too
                if recipeViewModel.flattenedIngredients[fromIndex].type == .title
                    && recipeViewModel.flattenedIngredients[safe: fromIndex - 1]?.type == .addButton {
                    recipeViewModel.flattenedIngredients.move(fromOffsets: IndexSet([fromIndex - 1, fromIndex]), toOffset: destination)
                    return
                }
            }
            
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
