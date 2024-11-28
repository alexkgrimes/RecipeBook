//
//  Orientation.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/27/24.
//

import Foundation
import SwiftUI

enum Orientation {
    case portrait
    case landscape
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

public extension View {
    internal func getSize(size: Binding<CGSize>, orientation: Binding<Orientation>) -> some View {
        background {
            GeometryReader { reader in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: reader.size)
            }
        }.onPreferenceChange(SizePreferenceKey.self) { newSize in
            size.wrappedValue = newSize
            
            if newSize.height > newSize.width {
                orientation.wrappedValue = .portrait
            } else {
                orientation.wrappedValue = .landscape
            }
        }
    }
}
