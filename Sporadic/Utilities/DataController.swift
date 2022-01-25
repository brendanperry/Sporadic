//
//  DataController.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/16/22.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let controller = NSPersistentCloudKitContainer(name: "sporadic")
    
    static let shared = DataController()
    
    private init() {
        controller.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error)")
            }
        }
        
        controller.viewContext.automaticallyMergesChangesFromParent = true
    }
}
