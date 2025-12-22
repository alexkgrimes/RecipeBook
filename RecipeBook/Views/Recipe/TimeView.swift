//
//  TimeView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/21/25.
//

import SwiftUI

struct TimeView: View {
    @State var showAllTimes: Bool = false
    let totalTime: Int
    let prepTime: Int?
    let cookTime: Int?
    
    var hasOtherTimes: Bool {
        prepTime != nil || cookTime != nil
    }
    
    var body: some View {
        Button {
            if hasOtherTimes { showAllTimes = true }
        } label: {
            HStack(alignment: .center, spacing: 8.0) {
                if let formatString = totalTime.timeString() {
                    Image(systemName: "clock")
                    Text("Total time: \(formatString)")
                }
            }
            .foregroundStyle(hasOtherTimes ? Color.accentColor : .secondary)
        }
        .popover(isPresented: $showAllTimes) {
            VStack {
                if let formatString = totalTime.timeString() {
                    Text("Total time: \(formatString)")
                }
                
                if let prepTime = prepTime, let formatString = prepTime.timeString() {
                    Text("Prep time: \(formatString)")
                }
                
                if let cookTime = cookTime, let formatString = cookTime.timeString() {
                    Text("Cook time: \(formatString)")
                }
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

extension Int {
    func timeString() -> String? {
        let hrs = self / 60
        let mins = self % 60
        if hrs > 0 && mins > 0 {
            return "\(hrs) hrs \(mins) mins"
        } else if mins > 0 {
            return "\(mins) mins"
        } else if hrs > 0 {
            return "\(hrs) hrs"
        } else {
            return nil
        }
    }
}
