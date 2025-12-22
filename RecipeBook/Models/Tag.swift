//
//  Tag.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/21/25.
//

import Foundation

final class Tag: Equatable, Codable, Identifiable, Hashable, Copyable {
    var id: UUID = UUID()
    var name: String = ""
    var colorString: String = ""
    
    init(name: String, colorString: String) {
        self.name = name
        self.colorString = colorString
    }
    
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.name != rhs.name {
            return false
        }
        if lhs.color != rhs.color {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(color)
    }
    
    func mutableCopy() -> Tag {
        return Tag(name: self.name, colorString: self.colorString)
    }
}
