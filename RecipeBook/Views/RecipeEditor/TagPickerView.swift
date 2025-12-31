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
    @State var currentTags: [Tag]
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if tagsModel.availableTags.isEmpty {
                    Text("No tags")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tagsModel.availableTags, id: \.self) { tag in
                        let isSelected = currentTags.contains(tag)
                        TagRadioButton(tag: tag, isSelected: isSelected, action: {
                            if isSelected {
                                currentTags.removeAll(where: { $0.id == tag.id })
                            } else {
                                currentTags.append(tag)
                            }
                        })
                    }
                    NavigationLink {
                        TagEditorView(editorMode: .new)
                    } label: {
                        Text("Create tag")
                            .frame(maxWidth: .infinity)
                    }
                    .padding([.top])
                    .navigationLinkIndicatorVisibility(.hidden)
                    .buttonStyle(.glass)
                }
                Spacer()
            }
            .padding()
            .frame(width: 400, height: 400)
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                if tagsModel.availableTags.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            TagEditorView(editorMode: .new)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            recipeViewModel.tags = currentTags
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}

struct TagRadioButton: View {
    let tag: Tag
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isSelected ? Color.accentColor : .gray)
            }
           
            Text("\(tag.name) ")
                .multilineTextAlignment(.leading)
                .padding([.leading, .trailing], 8.0)
                .padding([.top, .bottom], 5.0)
                .frame(maxWidth: .infinity, minHeight: 40.0)
                .foregroundColor(tag.color.isBright() ? .black : .white)
                .background(tag.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            NavigationLink(destination: TagEditorView(editorMode: .update, tag: tag), label: {
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.accentColor)
            })
            .navigationLinkIndicatorVisibility(.hidden)
        }
    }
}
