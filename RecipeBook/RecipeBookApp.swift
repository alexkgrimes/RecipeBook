//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftData
import SwiftUI

@main
struct RecipeBookApp: App {
    let persistenceController = PersistenceController.shared
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Recipe.self)
        } catch {
            fatalError("Failed to create ModelContainer for Recipe")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(modelContext: container.mainContext)
                .accentColor(Color.green)
        }
        .modelContainer(container)
    }
}
