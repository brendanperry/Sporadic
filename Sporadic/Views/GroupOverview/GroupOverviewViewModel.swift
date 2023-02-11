//
//  GroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import Foundation
import SwiftUI

class GroupOverviewViewModel: ObservableObject {
    @Published var emoji = "" {
        didSet {
            if !emoji.isSingleEmoji && !emoji.isEmpty {
                emoji = oldValue
            }
        }
    }
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var itemsCompleted = 4
    @Published var isOwner = true
    @Published var toolbarColor = Color("Panel")
    
    func updateToolbarColor(color: GroupBackgroundColor) {
        toolbarColor = color.getColor()
    }
    
    func checkOwnership(group: UserGroup) async {
        if let user = try? await CloudKitHelper.shared.getCurrentUser(forceSync: false) {
            DispatchQueue.main.async {
                self.isOwner = user.record.recordID == group.owner.recordID
            }
        }
    }
        
    func getTodayAtTimeOf(date: Date) -> Date {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? date
    }
    
    func save(group: UserGroup, completion: @escaping (Bool) -> Void) {
        itemsCompleted = 0
        
        saveGroup(group: group) { [weak self] didComplete in
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
        
        updateEditedActivities(group: group) { [weak self] didComplete in
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
        
        createNewActivities(group: group) { [weak self] didComplete in
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
        
        deleteActivities(group: group) { [weak self] didComplete in
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
    
    func deleteGroup(group: UserGroup, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        CloudKitHelper.shared.deleteGroup(recordId: group.record.recordID) { [weak self] error in
            DispatchQueue.main.async {
                if let _ = error {
                    self?.errorMessage = "Could not delete group. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
                else {
                    print("Group deleted")
                    group.wasDeleted = true
                    completion(true)
                }
                
                self?.isLoading = false
            }
        }
    }
    
    private func saveGroup(group: UserGroup, completion: @escaping (Bool) -> Void) {
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
    
    private func createNewActivities(group: UserGroup, completion: @escaping (Bool) -> Void) {
        let newActivities = group.activities.filter({ $0.isNew })
        if newActivities.isEmpty {
            completion(true)
            return
        }
        
        for activity in newActivities {
            CloudKitHelper.shared.createActivity(groupRecordId: group.record.recordID, name: activity.name, unit: activity.unit, minValue: activity.minValue, maxValue: activity.maxValue, templateId: activity.templateId ?? -1) { [weak self] result in
                
                switch result {
                case .success(_):
                    var activity = activity
                    activity.isNew = false
//
//                    DispatchQueue.main.async {
//                        self?.group.activities.removeAll(where: { $0.id == activity.id })
//                        self?.group.activities.append(activity)
//                    }
                    
                    completion(true)
                case .failure(_):
                    self?.errorMessage = "Could not save activity. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
            }
        }
    }
    
    private func updateEditedActivities(group: UserGroup, completion: @escaping (Bool) -> Void) {
        let editedActivities = group.activities.filter({ $0.wasEdited })
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
    
    private func deleteActivities(group: UserGroup, completion: @escaping (Bool) -> Void) {
        let deletedActivities = group.activities.filter({ $0.wasDeleted })
        
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
