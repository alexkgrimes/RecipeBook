//
//  RecipeLibraryView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/3/24.
//

import SwiftUI
import CoreData

struct RecipeLibraryView: View {
    var managedObjectContext: NSManagedObjectContext
    
    @StateObject private var model: RecipeLibraryViewModel
    @State private var showEditor: Bool = false
    @State private var addBook: Bool = false
    @Binding private var currentBook: RecipeBook?
    @State private var selectedBook: RecipeBook? = nil
    
    init(managedObjectContext: NSManagedObjectContext, currentBook: Binding<RecipeBook?>) {
        let model = RecipeLibraryViewModel(managedObjectContext: managedObjectContext)
        _model = StateObject(wrappedValue: model)
        _currentBook = currentBook
        self.managedObjectContext = managedObjectContext
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.recipeBooks) { book in
                    
                    HStack {
                        VStack(alignment: .leading) {
                            if currentBook?.uuid.uuidString == book.uuid.uuidString {
                                Text("Current Book")
                                    .foregroundStyle(Color.accentColor)
                            }
                            
                            Text(book.name)
                                .foregroundStyle(.primary)
                            Text("Private")
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            currentBook = book
                        }
                        
                        Spacer()
                        Button {
                            self.selectedBook = book
                            showEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Recipe Library")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        addBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                RecipeBookEditorView(editorMode: .update, 
                                     recipeBookViewModel: RecipeBookViewModel(recipeBook: selectedBook,
                                                                              managedObjectContext: managedObjectContext))
                    .presentationDetents([.fraction(0.3)])
            }
            .sheet(isPresented: $addBook) {
                RecipeBookEditorView(editorMode: .new,
                                     recipeBookViewModel: RecipeBookViewModel(managedObjectContext: managedObjectContext))
                .presentationDetents([.fraction(0.3)])
            }
        }
    }
}
