//
//  NotesView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/30/25.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    var body: some View {
        if !recipeViewModel.recipe.notes.isEmpty {
            VStack(alignment: .leading) {
                Text("Notes")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8.0)
                Text("\(recipeViewModel.recipe.notes)")
            }
        }
    }
}
