//
//  RecipeDetailView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @State var showEditor: Bool = false
    @State var cookModeOn: Bool = false
    @Binding var viewMode: RecipeViewMode
    
    @State private var orientation: Orientation = .portrait
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if orientation == .portrait {
                    VStack(alignment: .leading) {
                        headerView
                        ingredientsView
                        instructionsView
                    }
                    .padding(.all)
                } else {
                    
                    VStack(alignment: .leading) {
                        headerView
                        
                        HStack(alignment: .top) {
                            ingredientsView

                            Rectangle()
                                .frame(maxWidth: 1.0, maxHeight: .infinity)
                                .foregroundStyle(.tertiary)
                                .padding([.leading, .trailing], 16.0)

                            instructionsView
                            
                            Spacer()
                        }
                    }
                    .padding(.all)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewMode = .edit
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: cookModeOn) {
                UIApplication.shared.isIdleTimerDisabled = cookModeOn
            }
            .onDisappear() {
                cookModeOn = false
            }
        }
        .getSize(size: $screenSize, orientation: $orientation)
        .environmentObject(recipeViewModel)
    }
    
    @ViewBuilder var headerView: some View {
        HStack(alignment: .top, spacing: 8.0) {
            RecipeImage(recipeViewModel: recipeViewModel)
                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(recipeViewModel.recipe.title)
                    .foregroundStyle(.primary)
                    .font(.title)
                    .bold()
                if let url = recipeViewModel.recipe.url {
                    Button {
                        openURL(url)
                    } label: {
                        Text("View Original Recipe")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        Spacer(minLength: 16.0)
        
        HStack(alignment: .center, spacing: 32.0) {
            ServingsView(yield: recipeViewModel.recipe.yields)
            
            if let totalTime = recipeViewModel.recipe.totalTime {
                TimeView(totalTime: totalTime, prepTime: recipeViewModel.recipe.prepTime, cookTime: recipeViewModel.recipe.cookTime)
            }
            Spacer()
        }
        
        Toggle("Cook Mode", isOn: $cookModeOn)
            .foregroundStyle(.secondary)
        
        if !recipeViewModel.recipe.recipeDescription.isEmpty {
            Text(recipeViewModel.recipe.recipeDescription)
        }

        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 1.0)
            .foregroundStyle(.tertiary)
        
        Spacer(minLength: 16.0)
    }
    
    @ViewBuilder var ingredientsView: some View {
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.title2)
                .bold()
                .padding(.bottom, 8.0)
            
            ForEach(recipeViewModel.recipe.ingredientSections, id: \.self) { section in
                if !section.sectionName.isEmpty {
                    Text("\(section.sectionName)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .padding(.top, 2.0)
                }
                ForEach(section.listItems.indices, id: \.self) { index in
                    Text("• \(section.listItems[index])")
                    Spacer(minLength: 4.0)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder var instructionsView: some View {
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

struct TimeView: View {
    @State var showAllTimes: Bool = false
    let totalTime: Int
    let prepTime: Int?
    let cookTime: Int?
    
    var hasOtherTimes: Bool {
        prepTime != nil || cookTime != nil
    }
    
    var body: some View {
        Button {
            showAllTimes = true
        } label: {
            HStack(alignment: .center, spacing: 8.0) {
                Image(systemName: "clock")
                Text("\(totalTime) mins")
            }
            .foregroundStyle(hasOtherTimes ? Color.accentColor : .secondary)
        }
        .popover(isPresented: $showAllTimes) {
            VStack {
                Text("Total time: \(totalTime) mins")
                
                if let prepTime = prepTime {
                    Text("Prep time: \(prepTime) mins")
                }
                
                if let cookTime = cookTime {
                    Text("Cook time: \(cookTime) mins")
                }
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct ServingsView: View {
    @EnvironmentObject var recipeViewModel: RecipeViewModel
    let yield: String
    
    var body: some View {
        Text(yield)
            .foregroundStyle(.secondary)
    }
}
