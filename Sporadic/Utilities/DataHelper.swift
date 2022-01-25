//
//  DataHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/17/22.
//

import Foundation
import CoreData
import HealthKit

class DataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchActivities() -> [Activity]? {
        let fetchRequest = Activity.fetchRequest()
        
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
        challenge.amount = amount
        challenge.time = time
        challenge.isCompleted = false
        challenge.oneChallengeToOneActivity = activity
        
        try? context.save()
    }    
}
