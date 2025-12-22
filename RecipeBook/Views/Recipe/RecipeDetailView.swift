//
//  RecipeDetailView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI
import WebKit
import UIKit

struct RecipeDetailView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @State var showEditor: Bool = false
    @State var cookModeOn: Bool = false
    @State var servingMultiplier: ServingMultiplier = .one
    @Binding var viewMode: RecipeViewMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            RecipeContentView(headerView: { headerView },
                              videoPlaybackView: { videoPlaybackView },
                              descriptionView: {
                if !recipeViewModel.recipe.recipeDescription.isEmpty {
                    Text(recipeViewModel.recipe.recipeDescription)
                }
            },
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
        .environmentObject(recipeViewModel)
    }
    
    @ViewBuilder var headerView: some View {
        VStack {
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
                    ServingsView(recipeViewModel: recipeViewModel, servingMultiplier: $servingMultiplier)
                }
                Spacer()
            }
            Spacer(minLength: 16.0)
            
            HStack(alignment: .center, spacing: 32.0) {
                if let totalTime = recipeViewModel.recipe.totalTime {
                    TimeView(totalTime: totalTime, prepTime: recipeViewModel.recipe.prepTime, cookTime: recipeViewModel.recipe.cookTime)
                }
                Spacer()
            }
            
            if !recipeViewModel.recipe.tags.isEmpty {
                TagsView(tags: recipeViewModel.recipe.tags)
            }
            
            Toggle("Cook Mode", isOn: $cookModeOn)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder var videoPlaybackView: some View {
        if !recipeViewModel.recipe.videoURL.isEmpty,
           let urlComponents = URLComponents(string: recipeViewModel.recipe.videoURL),
           let queryItems = urlComponents.queryItems,
           let item = queryItems.first(where: { $0.name == "v" }),
           let videoID = item.value {
                VideoPlaybackView(videoID: videoID)
                    .frame(width: 533, height: 300)
                    .cornerRadius(10.0)
                    .shadow(radius: 5.0)

        }
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
