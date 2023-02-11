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
    var displayedDays: [Int]
    var deliveryTime: Date
    var emoji: String
    var backgroundColor: Int
    var name: String
    var record: CKRecord
    var activities = [Activity]()
    var users = [User]()
    var areActivitiesLoading = true
    var areUsersLoading = true
    var owner: CKRecord.Reference
    var wasDeleted = false
    
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
    
    // TODO: convert to property
    /// Converts the local delivery time to UTC and then converts that to an int based on how many 15 minute intervals it contains
    static func getDeliveryTimeInt(date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = .gmt
        
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        var intValue = 0
        
        if let hours = components.hour {
            var totalMinutes = hours * 60
            
            if let minutes = components.minute {
                totalMinutes += minutes
                
                intValue += Int((Double(totalMinutes) / 15.0).rounded(.towardZero))
            }
        }
        
        return intValue
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
