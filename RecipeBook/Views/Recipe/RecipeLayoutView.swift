//
//  RecipeLayoutView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/1/25.
//

import SwiftUI

struct RecipeContentView<HeaderView: View, VideoPlaybackView: View, IngredientsView: View, InstructionsView: View, NotesView: View>: View {
    @State private var orientation = UIDevice.current.orientation
    
    private let headerView: () -> HeaderView
    private let videoPlaybackView: () -> VideoPlaybackView
    private let ingredientsView: () -> IngredientsView
    private let instructionsView: () -> InstructionsView
    private let notesView: () -> NotesView
    
    init(@ViewBuilder headerView: @escaping () -> HeaderView,
         @ViewBuilder videoPlaybackView: @escaping () -> VideoPlaybackView,
         @ViewBuilder ingredientsView: @escaping () -> IngredientsView,
         @ViewBuilder instructionsView: @escaping () -> InstructionsView,
         @ViewBuilder notesView: @escaping () -> NotesView) {
        self.headerView = headerView
        self.videoPlaybackView = videoPlaybackView
        self.ingredientsView = ingredientsView
        self.instructionsView = instructionsView
        self.notesView = notesView
    }
    
    var body: some View {
        content()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
    }
    
    var shouldUseVStackOrientation: Bool {
        switch orientation {
        case .unknown, .portrait, .portraitUpsideDown, .faceUp, .faceDown:
            return true
        case .landscapeLeft, .landscapeRight:
            return false
        default:
            return true
        }
    }
    
    @ViewBuilder func content() -> some View {
        if shouldUseVStackOrientation {
            VStack(alignment: .leading) {
                headerView()
                videoPlaybackView()
                ingredientsView()
                instructionsView()
                notesView()
            }
            .padding(.all)
        } else {
            
            VStack(alignment: .leading) {
                headerView()
                
                HStack(alignment: .top) {
                    ingredientsView()
                    
                    Rectangle()
                        .frame(maxWidth: 1.0, maxHeight: .infinity)
                        .foregroundStyle(.tertiary)
                        .padding([.leading, .trailing], 16.0)
                    
                    instructionsView()
                    
                    Spacer()
                }
                notesView()
            }
            .padding(.all)
        }
    }
}
