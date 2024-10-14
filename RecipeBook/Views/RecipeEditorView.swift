//
//  RecipeEditorView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation
import SwiftUI

struct RecipeEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var recipe: Recipe
    var saveRecipe: (Recipe) -> ()
    
    var body: some View {
        NavigationStack {
            manualEntryForm
                .navigationTitle("New Recipe")
        }
    }
    
    @ViewBuilder
    var manualEntryForm: some View {
        Form {
            Section {
                AsyncImage(url: recipe.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .onAppear {
                            recipe.image = image.asUIImage().pngData()
                         }
                } placeholder: {
                    Color.red
                }
                .frame(maxHeight: 200)
                .clipShape(.rect(cornerRadius: 25))
            }
            .listRowInsets(EdgeInsets())
        
            Section("Title") {
                TextField("Title", text: $recipe.title)
            }
            
            Section("Ingredients") {
                ForEach(recipe.ingredients.indices, id: \.self) { index in
                    TextField("Enter ingredient", text: $recipe.ingredients[index], axis: .vertical)
                }
                
                Button {
                    if let last = recipe.ingredients.last, !last.isEmpty {
                        recipe.ingredients.append("")
                    }
                } label: {
                    Text("Add Ingredient")
                }
            }
            
            Section("Instructions") {
                ForEach(recipe.instructions.indices, id: \.self) { index in
                    TextField("Enter step", text: $recipe.instructions[index], axis: .vertical)
                }
                
                Button {
                    if let last = recipe.instructions.last, !last.isEmpty {
                        recipe.instructions.append("")
                    }
                } label: {
                    Text("Add Step")
                }
            }
            
            Button {
                recipe.ingredients = recipe.ingredients.filter { !$0.isEmpty }
                recipe.instructions = recipe.instructions.filter { !$0.isEmpty }
                saveRecipe(recipe)
                dismiss()
            } label: {
                Text("Save Recipe")
            }
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
