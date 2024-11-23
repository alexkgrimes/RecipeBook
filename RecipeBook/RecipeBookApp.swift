//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Alex Grimes on 8/25/24.
//

import SwiftUI

@main
struct RecipeBookApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController()

    var body: some Scene {
        WindowGroup {
            HomeView(managedObjectContext: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .accentColor(Color.green)
        }
        .onChange(of: scenePhase) { _, _ in
            persistenceController.save()
        }
    }
}
