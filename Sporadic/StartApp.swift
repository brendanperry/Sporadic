//
//  GCMiApp.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI

@main
struct StartApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, DataController.shared.controller.viewContext)
        }
    }
}
