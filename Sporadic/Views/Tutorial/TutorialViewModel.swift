//
//  TutorialViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/30/23.
//

import Foundation
import CloudKit
import UIKit
import SwiftUI

class TutorialViewModel: ObservableObject {
    @Published var selectedDifficulty = GroupDifficulty.beginner
    @Published var name = ""
    @Published var photo: UIImage? = nil
    @Published var group = UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "Group Deleted", owner: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"), streak: 0, bestStreak: 0)
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var selection = 0
    @Published var isLoading = false
    @Published var selectedTemplates = Set<ActivityTemplate>()
    
    func createGroup() {
        let deliveryTime = Date().addingTimeInterval(1800).nearest30Minutes()
        
        let activities = selectedTemplates.map {
            Activity(
                record: CKRecord(recordType: "Activity"),
                maxValue: $0.selectedMax,
                minValue: $0.selectedMin,
                name: $0.name,
                templateId: $0.id,
                unit: $0.unit,
                isNew: true)
        }
        
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        
        var days = [Int]()
        if var currentDay = components.weekday {
            days.append(currentDay)
            
            while days.count < 3 {
                if currentDay + 2 < 7 {
                    currentDay += 2
                    days.append(currentDay)
                } else {
                    currentDay = 0
                }
            }
        }
        
        CloudKitHelper.shared.createGroup(name: name + "'s Group", emoji: "💪", color: GroupBackgroundColor.one, days: days, time: deliveryTime, activities: activities) { result in
            print(result)
        }
    }

    func updateUser(updateSuccessful: @escaping () -> Void) {
        guard let user = CloudKitHelper.shared.getCachedUser() else {
            errorMessage = "No iCloud account was detected. Please make sure you are signed into your iCloud account and have an internet connection. Once this is done, restart the app and try again."
            showError = true
            isLoading = false
            
            return
        }
        
        user.name = name
        user.photo = photo
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        CloudKitHelper.shared.updateUserName(user: user) { [weak self] error in
            if let error {
                print(error)
                
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to update nickname. Please check your connection and try again."
                    self?.showError = true
                    self?.isLoading = false
                }
            }
            else {
                CloudKitHelper.shared.updateUserImage(user: user) { error in
                    if let error {
                        print(error)
                        
                        DispatchQueue.main.async {
                            self?.errorMessage = "Failed to update photo. Please check your connection and try again."
                            self?.showError = true
                            self?.isLoading = false
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            updateSuccessful()
                        }
                    }
                }
            }
        }
    }
}
