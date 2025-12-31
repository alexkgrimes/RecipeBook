//
//  IngredientsView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/30/25.
//

import SwiftUI

struct IngredientsView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    var servingMultiplier: ServingMultiplier
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.title2)
                .bold()
                .padding(.bottom, 8.0)
            
            ForEach(recipeViewModel.recipe.ingredientSections, id: \.self) { section in
                if !section.sectionName.isEmpty {
                    Text("\(section.sectionName)")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 2.0)
                }
                ForEach(section.listItems.indices, id: \.self) { index in
                    if servingMultiplier != .one {
                        let multipliedIngredient = section.listItems[index].numbersMultipliedBy(multiplier: servingMultiplier)
                        if multipliedIngredient == section.listItems[index] {
                            Text("• \(multipliedIngredient) \(Image(systemName: "exclamationmark.triangle.fill"))")
                        } else {
                            Text("• \(multipliedIngredient)")
                        }
                    } else {
                        Text("• \(section.listItems[index])")
                    }
                    Spacer(minLength: 4.0)
                }
            }
            
            Spacer()
        }
    }
}
