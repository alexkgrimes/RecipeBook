//
//  RecipeLayoutView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/1/25.
//

import SwiftUI

struct RecipeContentView<HeaderView: View, IngredientsView: View, InstructionsView: View, NotesView: View>: View {
    @State private var orientation: Orientation = .portrait
    @State private var screenSize: CGSize = .zero
    
    private let headerView: () -> HeaderView
    private let ingredientsView: () -> IngredientsView
    private let instructionsView: () -> InstructionsView
    private let notesView: () -> NotesView
    
    init(@ViewBuilder headerView: @escaping () -> HeaderView,
         @ViewBuilder ingredientsView: @escaping () -> IngredientsView,
         @ViewBuilder instructionsView: @escaping () -> InstructionsView,
         @ViewBuilder notesView: @escaping () -> NotesView) {
        self.headerView = headerView
        self.ingredientsView = ingredientsView
        self.instructionsView = instructionsView
        self.notesView = notesView
    }
    
    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .getSize(size: $screenSize, orientation: $orientation)
    }
    
    @ViewBuilder func content() -> some View {
       if orientation == .portrait {
            VStack(alignment: .leading) {
                headerView()
                ingredientsView()
                instructionsView()
                notesView()
            }
            .padding(.all)
        } else {
            
            VStack(alignment: .leading) {
                headerView()
                
                HStack(alignment: .top) {
                    ingredientsView()
                    
                    Rectangle()
                        .frame(maxWidth: 1.0, maxHeight: .infinity)
                        .foregroundStyle(.tertiary)
                        .padding([.leading, .trailing], 16.0)
                    
                    instructionsView()
                    
                    Spacer()
                }
                notesView()
            }
            .padding(.all)
        }
    }
}
