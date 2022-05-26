//
//  DataController.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/16/22.
//

import CoreData
import Foundation
import CloudKit

class DataController: ObservableObject, Repository {
    let container: NSPersistentCloudKitContainer
    
    static let shared = DataController()
    let oneSignalHelper = OneSignalHelper()
    
    private init() {
        container = NSPersistentCloudKitContainer(name: "sporadic")
        
        guard let description = container.persistentStoreDescriptions.first else {
             print("Can't set description")
             fatalError("Error")
         }
            
        description.cloudKitContainerOptions?.databaseScope = .public
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func fetchActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
        let activities = try? container.viewContext.fetch(fetchRequest)
        
        return activities
    }
    
    // when saving activities in iCloud
    // it is possible a user creates a new activity
    // then sync with iCloud later
    // we merge their stats and take the preferences of the most recent one
    func resolveDuplicateActivities() {
        let templateHelper = ActivityTemplateHelper()
        let activities = fetchActivities()
        let templates = templateHelper.getActivityTemplates()
        
        if let activities = activities {
            if activities.count > templates.count {
                for template in templates {
                    let name = template.name
                    
                    let activitiesForName = activities.filter({ $0.name == name })
                    
                    var challenges = [Challenge]()
                    var total = 0.0
                    for activity in activitiesForName {
                        if let activityChallenges = activity.challenges?.allObjects as? [Challenge] {
                            challenges.append(contentsOf: activityChallenges)
                        }
                        
                        total += activity.total
                    }
                    
                    guard let masterActivity = activitiesForName.first else {
                        continue
                    }
                    
                    masterActivity.total = total
                    for challenge in challenges {
                        challenge.activity = masterActivity
                    }
                    
                    for otherActivity in activitiesForName.filter({ $0.id != masterActivity.id }) {
                        container.viewContext.delete(otherActivity as NSManagedObject)
                    }
                }
            }
        }
    }
    
    func getTotalChallengesScheduled() -> Int {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let challenges = try? container.viewContext.fetch(fetchRequest)
        
        if let challenges = challenges {
            return challenges.count
        }
        
        return 0
    }
    
    func getDayAfterLastChallenge() -> Date? {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let challenges = try? container.viewContext.fetch(fetchRequest)
        
        if let challenges = challenges {
            let lastChallenge = challenges.sorted(by: { ($0.time ?? Date()) > ($1.time ?? Date()) }).first
            
            if let lastChallenge = lastChallenge {
                let date = lastChallenge.time
                
                return date
            }
        }
        
        return nil
    }
    
    func fetchActiveActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "isEnabled == true")
        
        let activities = try? container.viewContext.fetch(fetchRequest)
        
        return activities
    }
    
    func fetchInactiveActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "isEnabled == false")
        
        let activities = try? container.viewContext.fetch(fetchRequest)
        
        return activities
    }
    
    func fetchChallenges() -> [Challenge]? {
        let fetchRequest = Challenge.fetchRequest()
        
        let challenges = try? container.viewContext.fetch(fetchRequest)
        
        return challenges
    }
    
    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity) -> Challenge {
        let challenge = Challenge(context: container.viewContext)
        
        challenge.id = UUID()
        challenge.total = amount
        challenge.time = time
        challenge.isCompleted = false
        challenge.activity = activity
        
        saveChanges()
        
        return challenge
    }
    
    func setChallengeNotification(challenge: Challenge, notificationId: String) {
        challenge.notification = notificationId
        
        saveChanges()
    }
    
    func removeAllPendingChallenges() -> [String] {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let filtered = try? container.viewContext.fetch(fetchRequest)
        
        var notificationIds = [String]()
        
        if let filtered = filtered {
            for f in filtered {
                if let notification = f.notification {
                    notificationIds.append(notification)
                }
                
                container.viewContext.delete(f)
            }
        }
        
        saveChanges()
        return notificationIds
    }
    
    func fetchCurrentChallenge() -> Challenge? {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time >= %@ && time <= %@", getStartOfDay() as NSDate, getEndOfDay() as NSDate)
        
        return try? container.viewContext.fetch(fetchRequest).first
    }
    
    func saveChanges() {
        let context = container.viewContext
        
        if context.hasChanges {
            DispatchQueue.main.async {
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    internal func getStartOfDay() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 0
        components.minute = 00
        components.second = 00
        components.timeZone = TimeZone.current
            
        return Calendar.current.date(from: components)!
    }
                                    
    internal func getEndOfDay() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 23
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone.current
        
        return Calendar.current.date(from: components)!
    }
    

    internal func getComponentsFromDate(_ date: Date) -> DateComponents {
        let requestedComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]

        return Calendar.current.dateComponents(requestedComponents, from: date)
    }
}
