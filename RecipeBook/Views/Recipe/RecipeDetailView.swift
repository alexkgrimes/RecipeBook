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
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                RecipeContentView(headerView: { headerView },
                                  ingredientsView: { ingredientsView },
                                  instructionsView: { instructionsView },
                                  notesView: { notesView })
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
        .environmentObject(recipeViewModel)
    }
    
    @ViewBuilder var headerView: some View {
        HStack(alignment: .top, spacing: 8.0) {
            let imageSize = min(UIScreen.main.bounds.width / 3, UIScreen.main.bounds.height / 3)
            RecipeImage(recipeViewModel: recipeViewModel)
                .frame(width: imageSize, height: imageSize)
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(recipeViewModel.recipe.title)
                    .foregroundStyle(.primary)
                    .font(.title2)
                    .bold()
                if let url = recipeViewModel.recipe.url {
                    Button {
                        openURL(url)
                    } label: {
                        Text("View Original Recipe")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ServingsView(yield: recipeViewModel.recipe.yields)
            }
        }
        Spacer(minLength: 16.0)
        
        HStack(alignment: .center, spacing: 32.0) {
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
        
    @ViewBuilder var notesView: some View {
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
            if hasOtherTimes { showAllTimes = true }
        } label: {
            HStack(alignment: .center, spacing: 8.0) {
                if let formatString = totalTime.timeString() {
                    Image(systemName: "clock")
                    Text("Total time: \(formatString)")
                }
            }
            .foregroundStyle(hasOtherTimes ? Color.accentColor : .secondary)
        }
        .popover(isPresented: $showAllTimes) {
            VStack {
                if let formatString = totalTime.timeString() {
                    Text("Total time: \(formatString)")
                }
                
                if let prepTime = prepTime, let formatString = prepTime.timeString() {
                    Text("Prep time: \(formatString)")
                }
                
                if let cookTime = cookTime, let formatString = cookTime.timeString() {
                    Text("Cook time: \(formatString)")
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

extension Int {
    func timeString() -> String? {
        let hrs = self / 60
        let mins = self % 60
        if hrs > 0 && mins > 0 {
            return "\(hrs) hrs \(mins) mins"
        } else if mins > 0 {
            return "\(mins) mins"
        } else {
            return nil
        }
    }
}
