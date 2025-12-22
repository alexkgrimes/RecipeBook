//
//  TagsView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/21/25.
//

import SwiftUI
import UIKit

struct TagsView: View {
    let tags: [Tag]
    
    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                Text("\(tag.name)")
                    .padding([.leading, .trailing], 8.0)
                    .padding([.top, .bottom], 5.0)
                    .background(tag.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .foregroundColor(.white)
            }
        }
    }
}

extension Tag {
    var color: Color {
        return Color(hex: self.colorString) ?? .accentColor
    }
}

extension Color {
    /// Initializes a SwiftUI Color from a hex string (e.g., "#FF0000" or "FF0000" or "#43ff64d9").
    init?(hex: String) {
        // Use a UIColor initializer to handle the parsing
        guard let uiColor = UIColor(hex: hex) else {
            return nil
        }
        self.init(uiColor: uiColor)
    }
}

extension UIColor {
    /// Initializes a UIColor from a hex string.
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        // Check if string is 6 or 8 characters (RRGGBB or RRGGBBAA)
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: hexString)
        guard scanner.scanHexInt64(&rgbValue) else {
            return nil
        }

        var red, green, blue, alpha: UInt64
        switch hexString.count {
        case 6: // RRGGBB
            red = (rgbValue >> 16) & 0xFF
            green = (rgbValue >> 8) & 0xFF
            blue = rgbValue & 0xFF
            alpha = 255 // Opaque
        case 8: // RRGGBBAA or AARRGGBB - Common implementation is RRGGBBAA
            red = (rgbValue >> 24) & 0xFF
            green = (rgbValue >> 16) & 0xFF
            blue = (rgbValue >> 8) & 0xFF
            alpha = rgbValue & 0xFF
        default:
            return nil
        }

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }
}
