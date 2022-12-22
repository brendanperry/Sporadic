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
            
            group.emoji = emoji
        }
    }
    @Published var users = [User]()
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var itemsCompleted = 4
    
    init(group: UserGroup) {
        self.group = group
        emoji = group.emoji
        
        Task {
            async let activities: () = getActivities()
            async let users: () = getUsers()
            
            let _ = await (activities, users)
        }
    }
    
    func getTodayAtTimeOf(date: Date) -> Date {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? date
    }
    
    func getActivities() async {
        do {
            let activities = try await CloudKitHelper.shared.getActivitiesForGroup(group: group) ?? []
            
            DispatchQueue.main.async {
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
    
    func save(completion: @escaping (Bool) -> Void) {
        itemsCompleted = 0
        
        saveGroup { [weak self] didComplete in
            if didComplete == false {
                self?.isLoading = false
                completion(false)
            }
            else {
                DispatchQueue.main.async {
                    self?.itemsCompleted += 1
                }
            }
        }
        
        updateEditedActivities { [weak self] didComplete in
            if didComplete == false {
                self?.isLoading = false
                completion(false)
            }
            else {
                DispatchQueue.main.async {
                    self?.itemsCompleted += 1
                }
            }
        }
        
        createNewActivities { [weak self] didComplete in
            if didComplete == false {
                self?.isLoading = false
                completion(false)
            }
            else {
                DispatchQueue.main.async {
                    self?.itemsCompleted += 1
                }
            }
        }
        
        deleteActivities { [weak self] didComplete in
            if didComplete == false {
                self?.isLoading = false
                completion(false)
            }
            else {
                DispatchQueue.main.async {
                    self?.itemsCompleted += 1
                }
            }
        }
    }
    
    func deleteGroup(completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        CloudKitHelper.shared.deleteGroup(recordId: group.record.recordID) { [weak self] error in
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
    
    private func saveGroup(completion: @escaping (Bool) -> Void) {
        CloudKitHelper.shared.updateGroup(group: group, name: group.name, emoji: emoji, color: GroupBackgroundColor(rawValue: group.backgroundColor) ?? .one) { [weak self] error in
            if let error = error {
                print(error)
                
                DispatchQueue.main.async {
                    self?.errorMessage = "Could not save group changes. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
            }
            else {
                completion(true)
            }
        }
    }
    
    private func createNewActivities(completion: @escaping (Bool) -> Void) {
        let newActivities = activities.filter({ $0.isNew })
        
        if newActivities.isEmpty {
            completion(true)
            return
        }

        for activity in newActivities {
            CloudKitHelper.shared.createActivity(groupRecordId: group.record.recordID, name: activity.name, unit: activity.unit, minValue: activity.minValue, maxValue: activity.maxValue, templateId: activity.templateId ?? -1) { [weak self] error in
                if let _ = error {
                    self?.errorMessage = "Could not save activity. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
                else {
                    var activity = activity
                    activity.isNew = false
                    
                    DispatchQueue.main.async {
                        self?.activities.removeAll(where: { $0.id == activity.id })
                        self?.activities.append(activity)
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    private func updateEditedActivities(completion: @escaping (Bool) -> Void) {
        let editedActivities = activities.filter({ $0.wasEdited })
        
        if editedActivities.isEmpty {
            completion(true)
            return
        }

        for activity in editedActivities {
            CloudKitHelper.shared.updateActivity(activity: activity) { [weak self] error in
                if let _ = error {
                    self?.errorMessage = "Could not update activity. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
                else {
                    completion(true)
                }
            }
        }
    }
    
    private func deleteActivities(completion: @escaping (Bool) -> Void) {
        let deletedActivities = activities.filter({ $0.wasDeleted })
        
        if deletedActivities.isEmpty {
            completion(true)
            return
        }

        for activity in deletedActivities {
            if let recordId = activity.recordId {
                CloudKitHelper.shared.deleteRecord(recordId: recordId) { [weak self] error in
                    if let _ = error {
                        self?.errorMessage = "Could not update activity. Please check your connection and try again."
                        self?.showError = true
                        completion(false)
                    }
                    else {
                        completion(true)
                    }
                }
            }
        }
    }
}
