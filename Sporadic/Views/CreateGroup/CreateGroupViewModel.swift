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
    @Published var isLoading = false
    @Published var emoji = "🚲" {
        didSet {
            if !emoji.isSingleEmoji && !emoji.isEmpty {
                emoji = oldValue
            }
        }
    }
    @Published var days = 3
    @Published var time = Date()
    @Published var color = 1
    @Published var activities = [Activity]()
    @Published var errorMessage = ""
    @Published var showError = false
    
    var group = UserGroup.init(activities: nil, challenges: nil, displayedDays: [], daysPerWeek: 0, deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "", users: nil, record: CKRecord(recordType: "Group"))
    
    let activityTemplateHelper = ActivityTemplateHelper()
    
    func getTemplates() -> [ActivityTemplate] {
        return activityTemplateHelper.getActivityTemplates()
    }
    
    func createGroup(completion: @escaping (Bool) -> Void) {
        if groupName.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Group name cannot be empty."
                self.showError = true
                completion(false)
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        CloudKitHelper.shared.createGroup(name: groupName, emoji: emoji, color: GroupBackgroundColor(rawValue: color) ?? .one, days: days, time: time) { error in
            if error != nil {
                DispatchQueue.main.async {
                    self.errorMessage = "Could not create group. Please check your connection and try again."
                    self.showError = true
                    self.isLoading = false
                    completion(false)
                }
            }
            else {
                completion(true)
            }
        }
    }
}
