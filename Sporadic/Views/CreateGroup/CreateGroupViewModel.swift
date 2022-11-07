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
    
    var group = UserGroup.init(activities: nil, challenges: nil, availableDays: [], daysPerWeek: 0, deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "", users: nil, recordId: CKRecord(recordType: "Group").recordID)
    
    let activityTemplateHelper = ActivityTemplateHelper()
    
    func getTemplates() -> [ActivityTemplate] {
        return activityTemplateHelper.getActivityTemplates()
    }
    
    func createGroup() async -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        
        if groupName == "" {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Group name cannot be empty."
                self?.showError = true
            }
            
            isLoading = false
            return false
        }
        
        do {
            try await CloudKitHelper.shared.createGroup(name: groupName, emoji: emoji, color: GroupBackgroundColor(rawValue: color) ?? .one, days: days, time: time, activities: activities)
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            
            return true
        }
        catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Could not create group. Please check your connection and try again."
                self?.showError = true
                self?.isLoading = false
            }
            
            return false
        }
    }
}
