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
    var daysPerWeek: Int
    var deliveryTime: Date
    var emoji: String
    var backgroundColor: Int
    var name: String
    var record: CKRecord
    var activities = [Activity]()
    var users = [User]()
    
    init(activities: [CKRecord.Reference]?, challenges: [CKRecord.Reference]?, displayedDays: [Int], daysPerWeek: Int, deliveryTime: Date, emoji: String, backgroundColor: Int, name: String, users: [CKRecord.Reference]?, record: CKRecord) {
        self.displayedDays = displayedDays
        self.daysPerWeek = daysPerWeek
        self.deliveryTime = deliveryTime
        self.emoji = emoji
        self.backgroundColor = backgroundColor
        self.name = name
        self.record = record
    }
    
    // UTC adjusted days of the week
    var availableDays: [Int] {
        let hour = Calendar.current.component(.hour, from: deliveryTime)
        let minute = Calendar.current.component(.minute, from: deliveryTime)
        
        print(displayedDays)
        
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
            let activityReferences = record["activities"] as? [CKRecord.Reference]?,
            let challengeReferences = record["challenges"] as? [CKRecord.Reference]?,
            let userReferences = record["users"] as? [CKRecord.Reference]?,
            let displayedDays = record["displayedDays"] as? [Int]?,
            let deliveryTime = record["deliveryTime"] as? Date,
            let emoji = record["emoji"] as? String,
            let color = record["backgroundColor"] as? Int,
            let name = record["name"] as? String,
            let daysPerWeek = record["daysPerWeek"] as? Int
        else {
            return nil
        }
        
        self.init(activities: activityReferences, challenges: challengeReferences, displayedDays: displayedDays ?? [], daysPerWeek: daysPerWeek, deliveryTime: deliveryTime, emoji: emoji, backgroundColor: GroupBackgroundColor(rawValue: color)?.rawValue ?? 0, name: name, users: userReferences, record: record)
    }
}
