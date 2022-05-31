//
//  Group.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit
import SwiftUI

struct UserGroup: Identifiable {
    let id = UUID()
    let activities: [CKRecord.Reference]
    let challenges: [CKRecord.Reference]
    let daysOfTheWeek: [String]
    let deliveryTime: Date
    let emoji: String
    let backgroundColor: GroupBackgroundColor
    let name: String
    let users: [CKRecord.Reference]
}

// how to turn references into objects??
extension UserGroup {
    init? (from record: CKRecord) {
        guard
            let activityReferences = record["activities"] as? [CKRecord.Reference],
            let challengeReferences = record["challenges"] as? [CKRecord.Reference],
            let userReferences = record["users"] as? [CKRecord.Reference],
            let daysOfTheWeek = record["daysOfTheWeek"] as? [String],
            let deliveryTime = record["deliveryTime"] as? Date,
            let emoji = record["emoji"] as? String,
            let color = record["backgroundColor"] as? Int,
            let name = record["name"] as? String
        else {
            return nil
        }
        
        self.init(activities: activityReferences, challenges: challengeReferences, daysOfTheWeek: daysOfTheWeek, deliveryTime: deliveryTime, emoji: emoji, backgroundColor: GroupBackgroundColor(rawValue: color) ?? .red, name: name, users: userReferences)
    }
}

enum GroupBackgroundColor: Int {
    case red = 0
    case green = 1
    case blue = 2
}

extension GroupBackgroundColor {
    func getColor() -> Color {
        switch self {
        case .red:
            return Color.red
        case .green:
            return Color.green
        case .blue:
            return Color.blue
        }
    }
}
