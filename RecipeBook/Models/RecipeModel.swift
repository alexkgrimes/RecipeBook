//
//  RecipeModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

struct RecipeModel: Decodable {
    let instructions: [String]
    let ingredients: [String]
    let imageURL: URL?
}
