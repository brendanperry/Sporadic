//
//  GroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import Foundation
import SwiftUI
import CloudKit

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
        var recordsToSave = [CKRecord]()
        
        let groupRecord = group.record
        
        groupRecord.setValue(group.name, forKey: "name")
        groupRecord.setValue(emoji, forKey: "emoji")
        groupRecord.setValue(UserGroup.availableDays(deliveryTime: group.deliveryTime, displayedDays: group.displayedDays), forKey: "availableDays")
        groupRecord.setValue(group.displayedDays, forKey: "displayedDays")
        groupRecord.setValue(getTodayAtTimeOf(date: group.deliveryTime), forKey: "deliveryTime")
        groupRecord.setValue(group.backgroundColor, forKey: "backgroundColor")
        groupRecord.setValue(UserGroup.getDeliveryTimeInt(date: group.deliveryTime), forKey: "deliveryTimeInt")
        
        recordsToSave.append(groupRecord)
        
        let editedActivities = group.activities.filter({ $0.wasEdited })
        
        for activity in editedActivities {
            if let recordId = activity.recordId {
                let record = CKRecord(recordType: "Activity", recordID: recordId)
                record.setValue(activity.maxValue, forKey: "maxValue")
                record.setValue(activity.minValue, forKey: "minValue")
                
                recordsToSave.append(record)
            }
        }
        
        let newActivities = group.activities.filter({ $0.isNew })
        
        for activity in newActivities {
            let record = CKRecord(recordType: "Activity")
            
            let groupReference = CKRecord.Reference(recordID: groupRecord.recordID, action: .none)
            
            record.setValue(activity.templateId, forKey: "templateId")
            record.setValue(1, forKey: "isEnabled")
            record.setValue(activity.name, forKey: "name")
            record.setValue(activity.unit.rawValue, forKey: "unit")
            record.setValue(activity.minValue, forKey: "minValue")
            record.setValue(activity.maxValue, forKey: "maxValue")
            record.setValue(groupReference, forKey: "group")
            
            recordsToSave.append(record)
        }
        
        let deletedActivities = group.activities.filter({ $0.wasDeleted }).compactMap({ $0.recordId })
        
        CloudKitHelper.shared.database.modifyRecords(saving: recordsToSave, deleting: deletedActivities) { response in
            switch response {
            case .success(let results):
                print(results)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
        
//        saveGroup(group: group) { [weak self] didComplete in
//            if didComplete == false {
//                self?.isLoading = false
//                completion(false)
//            }
//            else {
//                DispatchQueue.main.async {
//                    self?.itemsCompleted += 1
//                }
//            }
//        }
//
//        updateEditedActivities(group: group) { [weak self] didComplete in
//            if didComplete == false {
//                self?.isLoading = false
//                completion(false)
//            }
//            else {
//                DispatchQueue.main.async {
//                    self?.itemsCompleted += 1
//                }
//            }
//        }
        
        // need to call these directly from the view so that we can update the binding groups
        
//        createNewActivities(group: group) { [weak self] didComplete in
//            if didComplete == false {
//                self?.isLoading = false
//                completion(false)
//            }
//            else {
//                DispatchQueue.main.async {
//                    self?.itemsCompleted += 1
//                }
//            }
//        }
//
//        deleteActivities(group: group) { [weak self] didComplete in
//            if didComplete == false {
//                self?.isLoading = false
//                completion(false)
//            }
//            else {
//                DispatchQueue.main.async {
//                    self?.itemsCompleted += 1
//                }
//            }
//        }
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
    
    private func createNewActivities(group: UserGroup, completion: @escaping ([Activity]?) -> Void) {
        let newActivities = group.activities.filter({ $0.isNew })
        if newActivities.isEmpty {
            completion([])
            return
        }
        
        CloudKitHelper.shared.createActivities(groupRecordId: group.record.recordID, activities: newActivities) { [weak self] result in
            switch result {
            case .success(let activities):
                completion(activities)
            case .failure(_):
                self?.errorMessage = "Could not save activity. Please check your connection and try again."
                self?.showError = true
                completion(nil)
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
