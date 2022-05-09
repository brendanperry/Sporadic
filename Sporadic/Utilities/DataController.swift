//
//  DataController.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/16/22.
//

import CoreData
import Foundation

class DataController: ObservableObject, Repository {
    let container: NSPersistentCloudKitContainer
    
    static let shared = DataController()
    
    private init() {
        container = NSPersistentCloudKitContainer(name: "sporadic")
        
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
    
    func getTotalChallengesScheduled() -> Int {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let challenges = try? container.viewContext.fetch(fetchRequest)
        
        if let challenges = challenges {
            return challenges.count
        }
        
        return 0
    }
    
    func popLastScheduledChallenge() -> Date? {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let challenges = try? container.viewContext.fetch(fetchRequest)
        
        if let challenges = challenges {
            let lastChallenge = challenges.sorted(by: { ($0.time ?? Date()) > ($1.time ?? Date()) }).first
            
            if let lastChallenge = lastChallenge {
                let date = lastChallenge.time
                container.viewContext.delete(lastChallenge)
                saveChanges()
                
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
    
    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity) {
        let challenge = Challenge(context: container.viewContext)
        
        challenge.id = UUID()
        challenge.total = amount
        challenge.time = time
        challenge.isCompleted = false
        challenge.oneChallengeToOneActivity = activity
        
        saveChanges()
    }
    
    func removeAllPendingChallenges() {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let filtered = try? container.viewContext.fetch(fetchRequest)
        
        if let filtered = filtered {
            for f in filtered {
                container.viewContext.delete(f)
            }
        }
        
        saveChanges()
    }
    
    func fetchCurrentChallenge() -> Challenge? {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time >= %@ && time <= %@", getStartOfDay() as NSDate, getEndOfDay() as NSDate)
        
        let challenges = try? container.viewContext.fetch(fetchRequest)
        
        if let challenges = challenges {
            for challenge in challenges {
                print("WOW: \(challenge.total)")
            }
        }
        
        return try? container.viewContext.fetch(fetchRequest).first
    }
    
    func saveChanges() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
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
