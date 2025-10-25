//
//  TitledList.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 10/25/25.
//

import Foundation

final class TitledList: Equatable, Codable, Identifiable, Hashable, Copyable {
    var id: UUID = UUID()
    var sectionName: String = ""
    var listItems: [String] = []
    
    init(sectionName: String, listItems: [String]) {
        self.sectionName = sectionName
        self.listItems = listItems
    }
    
    static func == (lhs: TitledList, rhs: TitledList) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.sectionName != rhs.sectionName {
            return false
        }
        if lhs.listItems.count != rhs.listItems.count {
            return false
        }
        for (i, lhsListItem) in lhs.listItems.enumerated() {
            if lhsListItem != rhs.listItems[i] {
                return false
            }
        }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(sectionName)
        hasher.combine(listItems)
    }
    
    func mutableCopy() -> TitledList {
        return TitledList(sectionName: self.sectionName, listItems: self.listItems)
    }
}

public enum FlattenedListType {
    case title
    case listItem
    case addButton
}

public struct FlattenedListItem {
    var type: FlattenedListType
    var text: String
    
    init(type: FlattenedListType, text: String) {
        self.type = type
        self.text = text
    }
}

extension [TitledList] {
    public var flattenedIngredients: [FlattenedListItem] {
        var flattened = [FlattenedListItem]()
        for section in self {
            flattened.append(.init(type: .title, text: section.sectionName))
            for ingredient in section.listItems {
                print("appending ingredient: \(ingredient)")
                flattened.append(.init(type: .listItem, text: ingredient))
            }
            flattened.append(.init(type: .addButton, text: "Add Ingredient"))
        }
        
        if flattened.isEmpty {
            flattened.append(.init(type: .addButton, text: "Add Ingredient"))
        }
        
        return flattened
    }
}
