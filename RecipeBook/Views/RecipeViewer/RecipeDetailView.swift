//
//  RecipeDetailView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/13/24.
//

import SwiftUI
import WebKit
import UIKit
import UniformTypeIdentifiers

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
            RecipeLayoutView(headerView: { headerView },
                              videoPlaybackView: { videoPlaybackView },
                              descriptionView: {
                if !recipeViewModel.recipe.recipeDescription.isEmpty {
                    Text(recipeViewModel.recipe.recipeDescription)
                }
            },
                             ingredientsView: {
                IngredientsView(recipeViewModel: recipeViewModel, servingMultiplier: servingMultiplier)
            },
                             instructionsView: {
                InstructionsView(recipeViewModel: recipeViewModel)
            },
                             notesView: {
                NotesView(recipeViewModel: recipeViewModel)
            })
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
             
            if let url = generateMultiPagePDF(from: RecipePDFView(recipeViewModel: recipeViewModel), fileName: "\(recipeViewModel.recipe.title)") {
                ToolbarItem(placement: .confirmationAction) {
                    ShareLink("Share?", item: url, subject: Text("subject"), message: Text("message"))
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
}
