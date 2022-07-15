//
//  Group.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit
import SwiftUI

class UserGroup: Identifiable {
    var id = UUID()
    var activities: [CKRecord.Reference]?
    let challenges: [CKRecord.Reference]?
    let daysOfTheWeek: [String]
    let daysPerWeek: Int
    let deliveryTime: Date
    let emoji: String
    let backgroundColor: Int
    let name: String
    let users: [CKRecord.Reference]?
    let recordId: CKRecord.ID
    
    init(activities: [CKRecord.Reference]?, challenges: [CKRecord.Reference]?, daysOfTheWeek: [String], daysPerWeek: Int, deliveryTime: Date, emoji: String, backgroundColor: Int, name: String, users: [CKRecord.Reference]?, recordId: CKRecord.ID) {
        self.activities = activities
        self.challenges = challenges
        self.daysOfTheWeek = daysOfTheWeek
        self.daysPerWeek = daysPerWeek
        self.deliveryTime = deliveryTime
        self.emoji = emoji
        self.backgroundColor = backgroundColor
        self.name = name
        self.users = users
        self.recordId = recordId
    }
}

extension UserGroup {
    convenience init? (from record: CKRecord) {
        guard
            let activityReferences = record["activities"] as? [CKRecord.Reference]?,
            let challengeReferences = record["challenges"] as? [CKRecord.Reference]?,
            let userReferences = record["users"] as? [CKRecord.Reference]?,
            let daysOfTheWeek = record["daysOfTheWeek"] as? [String],
            let deliveryTime = record["deliveryTime"] as? Date,
            let emoji = record["emoji"] as? String,
            let color = record["backgroundColor"] as? Int,
            let name = record["name"] as? String,
            let daysPerWeek = record["daysPerWeek"] as? Int
        else {
            return nil
        }
        
        self.init(activities: activityReferences, challenges: challengeReferences, daysOfTheWeek: daysOfTheWeek, daysPerWeek: daysPerWeek, deliveryTime: deliveryTime, emoji: emoji, backgroundColor: GroupBackgroundColor(rawValue: color)?.rawValue ?? 0, name: name, users: userReferences, recordId: record.recordID)
    }
}
