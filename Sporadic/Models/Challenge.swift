//
//  Challenge.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

struct Challenge: Identifiable {
    let id: UUID
    let activityRecord: CKRecord.Reference
    var activity: Activity? = nil
    let amount: Double
    let endTime: Date
    let startTime: Date
    let isCompleted: Bool
    let userRecords: [CKRecord.Reference]
    var users: [User]? = nil
    let group: CKRecord.Reference
    
    init(id: UUID, activityRecord: CKRecord.Reference, amount: Double, endTime: Date, startTime: Date, isCompleted: Bool, userRecords: [CKRecord.Reference], group: CKRecord.Reference) {
        self.id = id
        self.activityRecord = activityRecord
        self.amount = amount
        self.endTime = endTime
        self.startTime = startTime
        self.isCompleted = isCompleted
        self.userRecords = userRecords
        self.group = group
    }
}

enum ChallengeStatus {
    case completed, failed, inProgress
}

extension Challenge {
    init? (from record: CKRecord) {
        guard
            let activityReference = record["activity"] as? CKRecord.Reference,
            let amount = record["amount"] as? Double,
            let endTime = record["endTime"] as? Date,
            let startTime = record["startTime"] as? Date,
            let isCompleted = record["isCompleted"] as? Int,
            let users = record["users"] as? [CKRecord.Reference],
            let group = record["group"] as? CKRecord.Reference
        else {
            return nil
        }
        
        self = .init(id: UUID(), activityRecord: activityReference, amount: amount, endTime: endTime, startTime: startTime, isCompleted: isCompleted == 0 ? false : true, userRecords: users, group: group)
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
