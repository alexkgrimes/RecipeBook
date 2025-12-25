//
//  TagPickerView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/21/25.
//

import SwiftUI

struct TagPickerView: View {
    @EnvironmentObject var tagsModel: TagsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if tagsModel.availableTags.isEmpty {
                    Text("No tags")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tagsModel.availableTags, id: \.self) { tag in
                        HStack(alignment: .center) {
                            Text("\(tag.name) ")
                                .multilineTextAlignment(.leading)
                                .padding([.leading, .trailing], 8.0)
                                .padding([.top, .bottom], 5.0)
                                .frame(maxWidth: .infinity, minHeight: 40.0)
                                .background(tag.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .foregroundColor(tag.color.isBright() ? .black : .white)
                            
                            NavigationLink(destination: TagEditorView(editorMode: .update, tag: tag), label: {
                                Image(systemName: "square.and.pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color.accentColor)
                            })
                            .navigationLinkIndicatorVisibility(.hidden)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .frame(width: 400, height: 400)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        TagEditorView(editorMode: .new)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
                }
            }
        }
    }
}
