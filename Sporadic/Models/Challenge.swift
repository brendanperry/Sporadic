//
//  Challenge.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

class Challenge: Identifiable, ObservableObject {
    let id: UUID
    let activityRecord: CKRecord.Reference
    var activity: Activity? = nil
    let amount: Double
    let startTime: Date
    var isCompleted: Bool
    let userRecords: [CKRecord.Reference]
    @Published var users = [User]()
    let groupRecord: CKRecord.Reference
    @Published var group: UserGroup? = nil
    let recordId: CKRecord.ID
    
    init(id: UUID, activityRecord: CKRecord.Reference, amount: Double, startTime: Date, isCompleted: Bool, userRecords: [CKRecord.Reference], groupRecord: CKRecord.Reference, recordId: CKRecord.ID) {
        self.id = id
        self.activityRecord = activityRecord
        self.amount = amount
        self.startTime = startTime
        self.isCompleted = isCompleted
        self.userRecords = userRecords
        self.groupRecord = groupRecord
        self.recordId = recordId
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
            let startTime = record["startTime"] as? Date,
            let isCompleted = record["isCompleted"] as? Int,
            let users = record["users"] as? [CKRecord.Reference],
            let group = record["group"] as? CKRecord.Reference
        else {
            return nil
        }
        
        self.init(id: UUID(), activityRecord: activityReference, amount: amount, startTime: startTime, isCompleted: isCompleted == 0 ? false : true, userRecords: users, groupRecord: group, recordId: record.recordID)
    }
    
    func isChallengeFailed() -> Bool {
        return Date() > Calendar.current.date(byAdding: .day, value: 1, to: startTime) ?? startTime
    }
    
    func getStatus() -> ChallengeStatus {
        if self.isCompleted {
            return .completed
        }
        
        if !self.isCompleted && !isChallengeFailed() {
            return .inProgress
        }
        
        return .failed
    }
}
