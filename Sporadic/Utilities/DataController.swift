//
//  DataController.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/16/22.
//

import CoreData
import Foundation
import UserNotifications

class DataController: ObservableObject {
    let controller = NSPersistentCloudKitContainer(name: "sporadic")
    
    init() {
        controller.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error)")
            }
        }
        
        controller.viewContext.automaticallyMergesChangesFromParent = true

        let fetchRequest = Activity.fetchRequest()
        
        let activities = try? controller.viewContext.fetch(fetchRequest)

        if (activities?.count == 0 || activities == nil) {
            generateDefaultActivities()
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            if (notifications.count == 0) {
                let notificationHelper = NotificationHelper(context: self.controller.viewContext)

                notificationHelper.scheduleAllNotifications()
            }
        }
    }
    
    func fetchActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
        let activities = try? controller.viewContext.fetch(fetchRequest)
        
        return activities
    }
    
    func fetchChallenges() -> [Challenge]? {
        let fetchRequest = Challenge.fetchRequest()
        
        let challenges = try? controller.viewContext.fetch(fetchRequest)
        
        return challenges
    }
    
    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity) {
        let challenge = Challenge(context: controller.viewContext)
        
        challenge.id = UUID()
        challenge.amount = amount
        challenge.time = time
        challenge.isCompleted = false
        challenge.oneChallengeToOneActivity = activity
        
        try? controller.viewContext.save()
    }
    
    func generateDefaultActivities() {
        let run = Activity(context: controller.viewContext)
        run.id = UUID()
        run.name = "Run"
        run.minValue = 0.25
        run.maxValue = 26
        run.selectedMin = 1.0
        run.selectedMax = 3.0
        run.isEnabled = false
        run.total = 0
        run.unit = "miles"
        run.minRange = 0.25
        
        let bike = Activity(context: controller.viewContext)
        bike.id = UUID()
        bike.name = "Bike"
        bike.minValue = 0.5
        bike.maxValue = 50
        bike.selectedMin = 1.0
        bike.selectedMax = 3.0
        bike.isEnabled = false
        bike.total = 0
        bike.unit = "miles"
        bike.minRange = 0.5
        
        try? controller.viewContext.save()
    }
}
