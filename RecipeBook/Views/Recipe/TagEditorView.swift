//
//  TagEditorView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/21/25.
//

import SwiftUI

enum TagEditorMode {
    case new
    case update
}

struct TagEditorView: View {
    @EnvironmentObject var tagsModel: TagsViewModel
    @Environment(\.dismiss) var dismiss
    @State var editorMode: TagEditorMode
    @State var tag: Tag = Tag(name: "", colorString: "")
    @State private var selectedColor = Color.blue
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(tag.name) ")
                        .padding([.leading, .trailing], 8.0)
                        .padding([.top, .bottom], 5.0)
                        .foregroundColor(selectedColor.isBright() ? .black : .white)
                    
                    Spacer()
                }
                .background(tag.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(maxWidth: .infinity)
               
                TextField("Tag name", text: $tag.name, axis: .horizontal)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                
                CustomInlineColorPicker(selectedColor: $selectedColor, additionalColors: [tag.color])
                    .frame(maxWidth: .infinity)
                    .padding([.bottom])
                
                if editorMode == .update {
                    Button {
                        Task {
                            let success = await tagsModel.deleteTag(tag: tag)
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Delete tag")
                            .foregroundStyle(Color.red)
                    }
                }
               
                Spacer()
            }
            .onChange(of: selectedColor, initial: true) { _, newValue in
                if let hexString = selectedColor.toHexString() {
                    tag.colorString = hexString
                }
            }
            .onAppear {
                switch editorMode {
                case .new:
                    tag = Tag(name: "", colorString: "")
                case .update:
                    selectedColor = tag.color
                }
                
                if let hexString = selectedColor.toHexString() {
                    tag.colorString = hexString
                }
            }
            .padding()
            .navigationTitle(editorMode == .new ? "Add Tag" : "Edit Tag")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let success = await tagsModel.addTag(tag: tag)
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

struct CustomInlineColorPicker: View {
    @Binding var selectedColor: Color
    @State var colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .indigo, .mint, .cyan, .pink]
    var additionalColors: [Color] = []
    
    @State var newColor: Color = Color.blue
    
    // Define grid columns for layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) { // Use LazyVGrid for the layout
            ForEach(colors, id: \.self) { color in
                Button(action: {
                    selectedColor = color // Update the binding when a color is tapped
                }) {
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay( // Add an overlay to show the selected state
                            Circle()
                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                        )
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevents button from affecting list row highlighting
            }
        }
        .padding([.top, .bottom])
        .onAppear {
            var allColors = colors
            allColors.append(contentsOf: additionalColors)
        
            var results = [Color]()
            var seen = Set<Color>()
            for color in allColors {
                if !seen.contains(color) {
                    results.append(color)
                }
                seen.insert(color)
            }
            self.colors = results
        }
        
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                ColorPicker(selection: $newColor, label: {
                    Text("Custom")
                        .foregroundStyle(Color.primary)
                })
                
                Button {
                    selectedColor = newColor
                } label: {
                    Text("Use selected custom color")
                }
                .buttonStyle(.glass)
                .foregroundStyle(Color.accentColor)
            }
        }
        .padding([.top])
        .frame(maxWidth: .infinity)
    }
}

// Helper extension for text color contrast
extension Color {
    func isBright() -> Bool {
        // A simple check for perceived brightness to determine text color
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.5
    }
}

extension Color {
    func toHexString() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components [2])
        var a = Float (1.0)
        if components.count >= 4 {
            a = Float(components[3])
        }
        if a != Float (1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
