//
//  Challenge.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

class Challenge: Identifiable {
    let id: UUID
    let activity: CKRecord.Reference
    let amount: Double
    let endTime: Date
    let startTime: Date
    let isCompleted: Bool
    let users: [CKRecord.Reference]
    
    init(id: UUID, activity: CKRecord.Reference, amount: Double, endTime: Date, startTime: Date, isCompleted: Bool, users: [CKRecord.Reference]) {
        self.id = id
        self.activity = activity
        self.amount = amount
        self.endTime = endTime
        self.startTime = startTime
        self.isCompleted = isCompleted
        self.users = users
    }
}

enum ChallengeStatus {
    case completed, failed, inProgress
}

extension Challenge {
    convenience init? (from record: CKRecord) {
        guard
            let activityReference = record["activity"] as? CKRecord.Reference,
            let amount = record["amount"] as? Double,
            let endTime = record["endTime"] as? Date,
            let startTime = record["startTime"] as? Date,
            let isCompleted = record["isCompleted"] as? Int,
            let users = record["users"] as? [CKRecord.Reference]
        else {
            return nil
        }
        
        self.init(id: UUID(), activity: activityReference, amount: amount, endTime: endTime, startTime: startTime, isCompleted: isCompleted == 0 ? false : true, users: users)
    }
    
    func getStatus() -> ChallengeStatus {
        if self.isCompleted {
            return .completed
        }
        
        if !self.isCompleted && Date() < self.endTime {
            return .inProgress
        }
        
        return .failed
    }
}
