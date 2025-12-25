//
//  RecipeBookEditor.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/23/24.
//

import Foundation
import SwiftUI
import PhotosUI

enum RecipeBookEditorMode {
    case new
    case update
}

struct RecipeBookEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeBookViewModel: RecipeBookViewModel
    
    let editorMode: RecipeBookEditorMode
    var saveBook: ((RecipeBook) -> ())?
    
    init(editorMode: RecipeBookEditorMode, recipeBookViewModel: RecipeBookViewModel, saveBook: ((RecipeBook) -> ())? = nil) {
        self.editorMode = editorMode
        self.recipeBookViewModel = recipeBookViewModel
        self.saveBook = saveBook
    }
    
    var body: some View {
        NavigationStack {
            editorForm
                .navigationTitle(editorMode == .new ? "New Book" : "Update Book")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            editorMode == .new ? Text("Cancel") : Text("Close")
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    var editorForm: some View {
        Form {
            Section("Book Name") {
                TextField("Book Name", text: $recipeBookViewModel.recipeBook.name)
            }
            
            Button {
                switch editorMode {
                case .new:
                    recipeBookViewModel.addBook()
                case .update:
                    recipeBookViewModel.updateBook()
                }
                dismiss()
            } label: {
                Text("Save")
            }
        }
    }
}
