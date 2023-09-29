//
//  CompletedChallenge.swift
//  Sporadic
//
//  Created by Brendan Perry on 4/19/23.
//

import Foundation
import CloudKit

struct CompletedChallenge: Identifiable, Equatable {
    var id = UUID()
    let activityName: String
    var amount: Double
    let challenge: CKRecord.Reference
    let group: CKRecord.Reference
    let unit: String
    let user: CKRecord.Reference
    let date: Date
    let userName: String
    
    internal init(id: UUID = UUID(), activityName: String, amount: Double, challenge: CKRecord.Reference, group: CKRecord.Reference, unit: String, user: CKRecord.Reference, date: Date, userName: String) {
        self.id = id
        self.activityName = activityName
        self.amount = amount
        self.challenge = challenge
        self.group = group
        self.unit = unit
        self.user = user
        self.date = date
        self.userName = userName
    }
    
    init? (from record: CKRecord, group: UserGroup) {
        guard
            let activityName = record["activityName"] as? String,
            let userReference = record["user"] as? CKRecord.Reference,
            let groupReference = record["group"] as? CKRecord.Reference,
            let challengeReference = record["challenge"] as? CKRecord.Reference,
            let unit = record["unit"] as? String,
            let date = record["date"] as? Date,
            let amount = record["amount"] as? Double
        else {
            return nil
        }
        
        self.init(activityName: activityName, amount: amount, challenge: challengeReference, group: groupReference, unit: unit, user: userReference, date: date, userName: group.users.first(where: { $0.record.recordID == userReference.recordID })?.name ?? "")
    }
}
