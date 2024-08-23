//
//  CreateGroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import Foundation
import CloudKit
import SwiftUI

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
    @Published var days = [Int]()
    @Published var time = Date()
    @Published var color = 0 {
        didSet {
            toolbarBackground = GroupBackgroundColor.init(rawValue: color)?.getColor() ?? Color("Panel")
        }
    }
    @Published var activities = [Activity]()
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var toolbarBackground = GroupBackgroundColor.one.getColor()
    
    var group = UserGroup.init(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "", owner: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"), streak: 0, bestStreak: 0)
    
    
    func getTemplates() -> [ActivityTemplate] {
        return ActivityTemplateHelper.templates
    }
    
    func createGroup(completion: @escaping (UserGroup?) -> Void) {
        if groupName.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Group name cannot be empty."
                self.showError = true
                completion(nil)
            }
            
            return
        }
        
        if days.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "You must select days to receive challenges."
                self.showError = true
                completion(nil)
            }
            
            return
        }
        
        if activities.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "You must select at least one activity."
                self.showError = true
                completion(nil)
            }
            
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        CloudKitHelper.shared.createGroup(name: groupName, emoji: emoji, color: GroupBackgroundColor(rawValue: color) ?? .one, days: days, time: time, activities: activities) { [weak self] result in
            switch result {
            case .success(let group):
                group.areUsersLoading = false
                group.areActivitiesLoading = false
                completion(group)
            case .failure(_):
                DispatchQueue.main.async {
                    self?.errorMessage = "Could not create group. Please check your connection and try again."
                    self?.showError = true
                    self?.isLoading = false
                    completion(nil)
                }
            }
        }
    }
}
