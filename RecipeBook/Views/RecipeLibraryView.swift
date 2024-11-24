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
    @Binding private var currentBookID: UUID?
    @State private var selectedBook: RecipeBook? = nil
    
    init(managedObjectContext: NSManagedObjectContext, currentBookID: Binding<UUID?>) {
        let model = RecipeLibraryViewModel(managedObjectContext: managedObjectContext)
        _model = StateObject(wrappedValue: model)
        _currentBookID = currentBookID
        self.managedObjectContext = managedObjectContext
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.recipeBooks) { book in
                    
                    HStack {
                        VStack(alignment: .leading) {
                            if currentBookID?.uuidString == book.uuid.uuidString {
                                Text("Current Book")
                                    .foregroundStyle(.tertiary)
                            }
                            
                            Text(book.name)
                                .foregroundStyle(.primary)
                            Text("Private")
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            currentBookID = book.uuid
                        }
                        
                        Spacer()
                        Button {
                            self.selectedBook = book
                            showEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
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
