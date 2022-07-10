//
//  CreateGroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import Foundation
import CloudKit

class CreateGroupViewModel: ObservableObject {
    @Published var groupName = ""
    @Published var emoji = "🚲" {
        didSet {
            if !emoji.isSingleEmoji && !emoji.isEmpty {
                emoji = oldValue
            }
        }
    }
    @Published var color: GroupBackgroundColor = .one
    @Published var activities = [Activity]()
    @Published var errorMessage = ""
    @Published var showError = false
    
    let group = UserGroup.init(activities: nil, challenges: nil, daysOfTheWeek: [], daysPerWeek: 0, deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "", users: nil, usersInGroup: [], groupId: "", recordId: CKRecord(recordType: "Group").recordID)
    
    let activityTemplateHelper = ActivityTemplateHelper()
    
    func getTemplates() -> [ActivityTemplate] {
        return activityTemplateHelper.getActivityTemplates()
    }
    
    func createGroup() async {
        do {
            try await CloudKitHelper.shared.createGroup(name: groupName, emoji: emoji, color: color, activities: activities)
        }
        catch {
            print(error)
            errorMessage = "Could not create group. Please check your connection and try again."
            showError = true
        }
    }
}
