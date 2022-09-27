//
//  GroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import Foundation

class GroupOverviewViewModel: ObservableObject {
    @Published var group: UserGroup
    @Published var activities = [Activity]()
    @Published var emoji = "" {
        didSet {
            if !emoji.isSingleEmoji && !emoji.isEmpty {
                emoji = oldValue
            }
        }
    }
    @Published var users = [User]()
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    
    var currentDaysPerWeek = 0
    var currentDeliveryTime = Date()
    var currentChallengeDays = [String]()
    var currentName = ""
    var currentEmoji = ""
    var currentColor = 1
    var currentActivities = [Activity]()
    
    init(group: UserGroup) {
        self.group = group
        
        currentDaysPerWeek = group.daysPerWeek
        currentDeliveryTime = group.deliveryTime
        currentChallengeDays = group.daysOfTheWeek
        currentName = group.name
        currentEmoji = group.emoji
        currentColor = group.backgroundColor
        emoji = group.emoji
        
        Task {
            await getActivities()
            await getUsers()
        }
    }
    
    func getActivities() async {
        do {
            let activities = try await CloudKitHelper.shared.getActivitiesForGroup(group: group) ?? []
            
            DispatchQueue.main.async {
                self.currentActivities = activities
                self.activities = activities
            }
        }
        catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not load group activities."
                self.showError = true
            }
        }
    }
    
    func getUsers() async {
        do {
            let users = try await CloudKitHelper.shared.getUsersForGroup(group: group) ?? []
            
            DispatchQueue.main.async {
                self.users = users
            }
        }
        catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not load group users."
                self.showError = true
            }
        }
    }
    
    func deleteGroup(completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        CloudKitHelper.shared.deleteGroup(recordId: group.recordId) { [weak self] error in
            DispatchQueue.main.async {
                if let _ = error {
                    self?.errorMessage = "Could not delete group. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
                else {
                    completion(true)
                }
                
                self?.isLoading = false
            }
        }
    }
    
    func saveGroup() {
        if currentName != group.name
            || currentEmoji != emoji
            || currentColor != group.backgroundColor
            || currentDeliveryTime != group.deliveryTime
            || currentDaysPerWeek != group.daysPerWeek
            || currentChallengeDays != group.daysOfTheWeek
            || currentActivities != activities {
            
            CloudKitHelper.shared.updateGroup(group: group, name: group.name, emoji: emoji, color: GroupBackgroundColor(rawValue: group.backgroundColor) ?? .one, days: group.daysPerWeek, time: group.deliveryTime, daysOfTheWeek: group.daysOfTheWeek) { [weak self] error in
                if error != nil {
                    
                    DispatchQueue.main.async {
                        self?.errorMessage = "Could not save group changes. Please check your connection and try again."
                        self?.showError = true
                    }
                }
            }
        }
    }
    
    func saveActivities() {
        let currentActivityIds = currentActivities.map { $0.id }
        let newActivities = activities.filter({ !currentActivityIds.contains($0.id) })
        
        for activity in newActivities {
            CloudKitHelper.shared.addActivityToGroup(groupRecordId: group.recordId, name: activity.name, unit: activity.unit, minValue: activity.minValue, maxValue: activity.maxValue, templateId: activity.templateId ?? -1) { [weak self] reference in
                if reference == nil {
                    
                    DispatchQueue.main.async {
                        self?.errorMessage = "Could not save activity. Please check your connection and try again."
                        self?.showError = true
                    }
                }
            }
        }
        
        currentActivities = activities
    }
}
