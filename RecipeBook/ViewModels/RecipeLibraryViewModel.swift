//
//  RecipeLibraryViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/23/24.
//

import Foundation
import SwiftUI

@MainActor
class RecipeLibraryViewModel: ObservableObject {
    @Published var recipeBooks = [RecipeBook]()
}
