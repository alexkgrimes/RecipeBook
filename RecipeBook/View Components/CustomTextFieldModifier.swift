//
//  CustomTextFieldModifier.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/1/25.
//

import SwiftUI

struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.all, 14.0)
            .background(RoundedRectangle(cornerRadius: 8.0)
                .fill(Color(uiColor: UIColor.secondarySystemGroupedBackground)))
    }
}

extension View {
    func customTextFieldStyle() -> some View {
        modifier(CustomTextFieldModifier())
    }
}
