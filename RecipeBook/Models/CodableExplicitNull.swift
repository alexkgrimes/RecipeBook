//
//  CodableExplicitNull.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/23/25.
//

import Foundation

@propertyWrapper
public struct CodableExplicitNull<Wrapped> {
    public var wrappedValue: Wrapped?
    
    public init(wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }
}

extension CodableExplicitNull: Encodable where Wrapped: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}

extension CodableExplicitNull: Decodable where Wrapped: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            wrappedValue = try container.decode(Wrapped.self)
        }
    }
}

extension CodableExplicitNull: Equatable where Wrapped: Equatable { }

extension KeyedDecodingContainer {
    
    public func decode<Wrapped>(_ type: CodableExplicitNull<Wrapped>.Type,
                                forKey key: KeyedDecodingContainer<K>.Key) throws -> CodableExplicitNull<Wrapped> where Wrapped: Decodable {
        return try decodeIfPresent(CodableExplicitNull<Wrapped>.self, forKey: key) ?? CodableExplicitNull<Wrapped>(wrappedValue: nil)
    }
}
