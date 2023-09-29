//
//  Group.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit
import SwiftUI

class UserGroup: Identifiable, ObservableObject, Hashable, Equatable {
    static func == (lhs: UserGroup, rhs: UserGroup) -> Bool {
        return lhs.record.recordID == rhs.record.recordID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(record.recordID)
    }
    
    @Published var displayedDays: [Int]
    @Published var deliveryTime: Date
    @Published var emoji: String
    @Published var backgroundColor: Int
    @Published var name: String
    var record: CKRecord
    @Published var activities = [Activity]()
    @Published var users = [User]()
    @Published var areActivitiesLoading = true
    @Published var areUsersLoading = true
    @Published var owner: CKRecord.Reference
    @Published var wasDeleted = false
    var createdAt = Date()
    
    init(displayedDays: [Int], deliveryTime: Date, emoji: String, backgroundColor: Int, name: String, owner: CKRecord.Reference, record: CKRecord) {
        self.displayedDays = displayedDays
        self.deliveryTime = deliveryTime
        self.emoji = emoji
        self.backgroundColor = backgroundColor
        self.name = name
        self.record = record
        self.owner = owner
    }
    
    // UTC adjusted days of the week
    static func availableDays(deliveryTime: Date, displayedDays: [Int]) -> [Int] {
        let hour = Calendar.current.component(.hour, from: deliveryTime)
        let minute = Calendar.current.component(.minute, from: deliveryTime)
        
        var days = [Int]()
        for day in displayedDays {
            let components = DateComponents(calendar: .current, hour: hour, minute: minute, weekday: day)
            let localDate = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) ?? Date()
            let gmtDate = localDate.toGlobalTime()
            let adjustedWeekDay = Calendar.current.component(.weekday, from: gmtDate)
            
            days.append(adjustedWeekDay)
        }
        
        return days
    }
}

extension UserGroup {
    convenience init? (from record: CKRecord) {
        guard
            let displayedDays = record["displayedDays"] as? [Int]?,
            let deliveryTime = record["deliveryTime"] as? Date,
            let emoji = record["emoji"] as? String,
            let color = record["backgroundColor"] as? Int,
            let name = record["name"] as? String,
            let owner = record["owner"] as? CKRecord.Reference?
        else {
            return nil
        }
        
        self.init(displayedDays: displayedDays ?? [], deliveryTime: deliveryTime, emoji: emoji, backgroundColor: GroupBackgroundColor(rawValue: color)?.rawValue ?? 0, name: name, owner: owner ?? CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: record)
    }
}
