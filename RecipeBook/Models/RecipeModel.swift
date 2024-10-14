//
//  RecipeModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 9/29/24.
//

import Foundation

struct RecipeModel: Decodable {
    let instructions: String?
    let ingredients: [String]?
    let image: URL?
    let cookTime: Int?
    let cuisine: String?
    let prepTime: Int?
    let totalTime: Int?
    let title: String?
    let description: String?
    let author: String?
    let canonicalUrl: URL?
    let category: String?
    let host: String?
    let nutrients: [String: String]?
    let ratings: Double?
    let siteName: String?
    let yields: String?
}
