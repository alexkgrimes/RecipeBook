//
//  RecipeLibraryView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/3/24.
//

import SwiftUI
import CoreData

struct RecipeLibraryView: View {
    
    @StateObject private var model: RecipeLibraryViewModel
    @State private var showEditor: Bool = false
    @Binding private var currentBookID: UUID?
    
    init(managedObjectContext: NSManagedObjectContext, currentBookID: Binding<UUID?>) {
        let model = RecipeLibraryViewModel(managedObjectContext: managedObjectContext)
        _model = StateObject(wrappedValue: model)
        _currentBookID = currentBookID
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.recipeBooks.indices, id: \.self) { index in
                    
                    let recipeBook = model.recipeBooks[index]
                    HStack {
                        if currentBookID?.uuidString == recipeBook.uuid.uuidString {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.primary)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(recipeBook.name)
                                .foregroundStyle(.primary)
                            Text("Private")
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Recipe Library")
            .sheet(isPresented: $showEditor) {
                EmptyView()
            }
        }
    }
}
