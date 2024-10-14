//
//  HomeView.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var inputURL: Bool = false
    @State private var inputRecipe: Bool = false
    
    @State private var inProgressRecipe: Recipe = Recipe.emptyRecipe()
    @State private var model: HomeViewModel
    
    init(modelContext: ModelContext) {
        let model = HomeViewModel(modelContext: modelContext)
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(model.recipes) { recipe in
                    RecipeRowView(recipe: recipe)
                }
                .onDelete { (indexSet) in
                    model.deleteRecipe(at: indexSet)
                }
            }
            .sheet(isPresented: $inputURL, onDismiss: {
                inputRecipe = true
            }) {
                URLInputView(inProgressRecipe: $inProgressRecipe)
                    .presentationDetents([.fraction(0.3)])
                
            }
            .sheet(isPresented: $inputRecipe) {
                RecipeEditorView(recipe: $inProgressRecipe) { recipe in
                    model.add(recipe: recipe)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        inputURL = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(modelContext: try! ModelContext(ModelContainer.init()))
    }
}
