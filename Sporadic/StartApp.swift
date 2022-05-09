//
//  GCMiApp.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI

@main
struct StartApp: App {
    let dataController = DataController.shared
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
                    dataController.saveChanges()
                })
        }
        .onChange(of: scenePhase) { _ in
            dataController.saveChanges()
        }
    }
}
