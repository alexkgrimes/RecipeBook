//
//  TagsViewModel.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/21/25.
//

import SwiftUI

@MainActor
class TagsViewModel: ObservableObject {
    @Published var availableTags = [Tag]()
    
    public func dataInitialization() {
        Task {
            let tags = await WebService.fetchTags()
            availableTags = tags
        }
    }
    
    public func addTag(tag: Tag) async -> Bool {
        let success = await WebService.addTag(newTag: tag)
        dataInitialization()
        return success
    }
    
    public func deleteTag(tag: Tag) async -> Bool {
        let success = await WebService.removeTag(uuid: tag.id)
        dataInitialization()
        return success
    }
}
