//
//  HomeViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerViewModel: ObservableObject {
    @Binding var recipe: Recipe
    
    init(recipe: Binding<Recipe>) {
        self._recipe = recipe
    }
    
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection = selection else {
            return
        }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                recipe.image = data
            }
        }
    }
}
