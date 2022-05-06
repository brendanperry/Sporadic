//
//  DataHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/17/22.
//

import Foundation
import CoreData

class DataHelper: Repository {
    let context = DataController.shared.controller.viewContext
    
    func fetchActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
        let activities = try? context.fetch(fetchRequest)
        
        return activities
    }
    
    func getTotalChallengesScheduled() -> Int {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let challenges = try? context.fetch(fetchRequest)
        
        if let challenges = challenges {
            return challenges.count
        }
        
        return 0
    }
    
    func popLastScheduledChallenge() -> Date? {
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let challenges = try? context.fetch(fetchRequest)
        
        if let challenges = challenges {
            let lastChallenge = challenges.sorted(by: { ($0.time ?? Date()) > ($1.time ?? Date()) }).first
            
            if let lastChallenge = lastChallenge {
                let date = lastChallenge.time
                context.delete(lastChallenge)
                
                return date
            }
        }
        
        return nil
    }
    
    func fetchActiveActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "isEnabled == true")
        
        let activities = try? context.fetch(fetchRequest)
        
        return activities
    }
    
    func fetchChallenges() -> [Challenge]? {
        let fetchRequest = Challenge.fetchRequest()
        
        let challenges = try? context.fetch(fetchRequest)
        
        return challenges
    }
    
    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity) {
        let challenge = Challenge(context: context)
        
        challenge.id = UUID()
        challenge.total = amount
        challenge.time = time
        challenge.isCompleted = false
        challenge.oneChallengeToOneActivity = activity
        
        try? context.save()
    }
    
    func removeAllPendingChallenges() {        
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time > %@", getEndOfDay() as NSDate)
        
        let filtered = try? context.fetch(fetchRequest)
        
        if let filtered = filtered {
            for f in filtered {
                context.delete(f)
            }
            
            try? context.save()
        }
    }
    
    func fetchCurrentChallenge() -> Challenge? {        
        let fetchRequest = Challenge.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "time >= %@ && time <= %@", getStartOfDay() as NSDate, getEndOfDay() as NSDate)
        
        return try? context.fetch(fetchRequest).first
    }
    
    func getStartOfDay() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 0
        components.minute = 00
        components.second = 00
        components.timeZone = TimeZone.current
            
        return Calendar.current.date(from: components)!
    }
                                    
    func getEndOfDay() -> Date {
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
    
    func saveChanges() {
        try? context.save()
    }
}
