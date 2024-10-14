//
//  RecipeDetailView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(recipe.title)
                        .foregroundStyle(.green)
                        .font(.headline)
                        .bold()
                    
                    RecipeImage(recipe: recipe)
                        .frame(maxHeight: 200)
                        .clipShape(.rect(cornerRadius: 25))
                    
                    Spacer(minLength: 16.0)
                    
                    HStack {
                        Spacer()
                        MetadataView(title: "Total Time", subtitle: "\(recipe.totalTime) mins")
                        Spacer()
                        MetadataView(title: "Servings", subtitle: recipe.yields)
                        Spacer()
                    }
                    
                    Spacer(minLength: 16.0)
                    
                    Text("Ingredients")
                        .bold()
                    ForEach(recipe.ingredients.indices, id: \.self) { index in
                        Text("• \(recipe.ingredients[index])")
                    }
                    
                    Spacer(minLength: 16.0)
                    
                    Text("Instructions")
                        .bold()
                    ForEach(recipe.instructions.indices, id: \.self) { index in
                        Text("\(index + 1). \(recipe.instructions[index])")
                    }
                }
                .padding(.all)
            }
        }
    }
}

struct MetadataView: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }
}
