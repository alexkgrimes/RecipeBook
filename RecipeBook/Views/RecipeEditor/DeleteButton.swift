//
//  DeleteButton.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/20/25.
//

import SwiftUI

struct DeleteButton: View {
    @State var showDeleteConfirmation: Bool = false
    var editorMode: RecipeEditorMode
    var deleteAction: () -> Void
    
    var body: some View {
        if editorMode == .update {
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .confirmationDialog(Text("Delete Recipe?"),
                                isPresented: $showDeleteConfirmation,
                                titleVisibility: .visible,
                                actions: {
                
                Button("Delete", role: .destructive) {
                    deleteAction()
                }
                
                Button("Cancel") { }
            })
        }
    }
}
