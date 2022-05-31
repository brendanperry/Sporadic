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
    let activity: CKRecord.Reference
    let amount: Double
    let endTime: Date
    let startTime: Date
    let isCompleted: Bool
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
            let isCompleted = record["isCompleted"] as? Int
        else {
            return nil
        }
        
        self = .init(id: UUID(), activity: activityReference, amount: amount, endTime: endTime, startTime: startTime, isCompleted: isCompleted == 0 ? false : true)
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
