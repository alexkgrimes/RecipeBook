//
//  InstructionsView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/30/25.
//

import SwiftUI

struct InstructionsView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Instructions")
                .font(.title2)
                .bold()
                .padding(.bottom, 8.0)
            
            ForEach(recipeViewModel.recipe.instructionSections, id: \.self) { section in
                if !section.sectionName.isEmpty {
                    Text("\(section.sectionName)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .padding(.top, 2.0)
                }
                ForEach(section.listItems.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8.0) {
                        Text("\(index + 1)")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.accentColor)
                        
                        Text("\(section.listItems[index])")
                    }
                }
            }
            Spacer()
        }
    }
}
