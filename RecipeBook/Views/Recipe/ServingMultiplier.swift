//
//  ServingMultiplier.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/21/25.
//

import Foundation
import SwiftUI

enum ServingMultiplier: Int {
    case one = 1
    case two = 2
    case three = 3
}

struct ServingsView: View {
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Binding var servingMultiplier: ServingMultiplier
    
    var body: some View {
        Picker("", selection: $servingMultiplier) {
            Text("1x").tag(ServingMultiplier.one)
            Text("2x").tag(ServingMultiplier.two)
            Text("3x").tag(ServingMultiplier.three)
        }
        .frame(width: 160)
        .pickerStyle(SegmentedPickerStyle())
        
        Text(recipeViewModel.recipe.yields.numbersMultipliedBy(multiplier: servingMultiplier))
            .foregroundStyle(.secondary)
    }
}

enum NumericValue {
    case int(Int)
    case double(Double)
    // A simple tuple can represent a fraction (numerator, denominator)
    case fraction((whole: Int, numerator: Int, denominator: Int))
    
    func multipliedBy(multiplier: ServingMultiplier) -> NumericValue {
        switch self {
        case .int(let num):
            return .int(num * multiplier.rawValue)
        case .double(let num):
            return .double(num * Double(multiplier.rawValue))
        case .fraction((let whole, let num, let denom)):
            var multipliedNumerator = num * multiplier.rawValue
            var multipliedWhole = whole * multiplier.rawValue
            multipliedWhole += (multipliedNumerator / denom)
            multipliedNumerator = multipliedNumerator % denom
            
            let gcd = gcd(multipliedNumerator, denom)
            return .fraction((multipliedWhole, multipliedNumerator / gcd, denom / gcd))
        }
    }
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        var num1 = a
        var num2 = b
        while num2 != 0 {
            let remainder = num1 % num2
            num1 = num2
            num2 = remainder
        }
        return num1
    }
    
    func toString() -> String {
        switch self {
        case .int(let num):
            return "\(num)"
        case .double(let num):
            return "\(num)"
        case .fraction((let whole, let numerator, let denominator)):
            let hideFraction = numerator == 0
            
            if whole == 0 {
                return "\(numerator)/\(denominator)"
            } else {
                return hideFraction ? "\(whole)" : "\(whole) \(numerator)/\(denominator)"
            }
        }
    }
}

extension String {
    func numbersMultipliedBy(multiplier: ServingMultiplier) -> String {
        guard multiplier != .one else {
            return self
        }
        
        var multipliedStringArray: [String] = []
        let basicWords = self.components(separatedBy: " ")
        var words: [String] = []
        
        // Combine compound numbers like 1 1/2
        for word in basicWords {
            if let numberValue = word.numberValue() {
                if let previousWord = words.last, let previousNumber = previousWord.numberValue() {
                    words[words.count - 1].append(" \(word)")
                } else {
                    words.append(word)
                }
            } else {
                words.append(word)
            }
        }
        
        // Multiply the numbers
        for word in words {
            guard let numberValue = word.numberValue() else {
                multipliedStringArray.append(word)
                continue
            }
            let multipliedNumber = numberValue.multipliedBy(multiplier: multiplier)
            multipliedStringArray.append(multipliedNumber.toString())
        }
        
        var multipliedString = ""
        for (index, word) in multipliedStringArray.enumerated() {
            multipliedString.append(word)
            if index < multipliedStringArray.count - 1 {
                multipliedString.append(" ")
            }
        }
        return multipliedString
    }
    
    func numberValue() -> NumericValue? {
        if let number = Int(self) {
            print("Successfully converted Int: \(number)")
            return .int(number)
        } else if let number = Double(self) {
            print("Successfully converted Double: \(number)")
            return .double(number)
        }
        
        var wholeNumber = 0
        var potentionFractionString = self
        if self.contains(" ") {
            let compoundNumber = self.components(separatedBy: " ")
            if let firstComponent = compoundNumber[safe: 0], let number = Int(firstComponent) {
                print("whole number: \(number)")
                wholeNumber = number
            }
            
            if let secondComponent = compoundNumber[safe: 1] {
                potentionFractionString = secondComponent
            }
        }
        
        let slashCount = potentionFractionString.filter { $0 == "/" }.count
        if slashCount == 1, let slashIndex = potentionFractionString.firstIndex(of: "/") {
            let numeratorString = potentionFractionString.substring(to: slashIndex)
            print("potential numerator: \(numeratorString)")
            
            let denomimatorString = potentionFractionString.substring(from: self.index(after: slashIndex))
            print("potential denominator: \(denomimatorString)")
            
            if let numerator = Int(numeratorString), let denominator = Int(denomimatorString) {
                return .fraction((wholeNumber, numerator, denominator))
            }
        }
        return nil
    }
}
