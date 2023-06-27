//
//  HomeViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation
import CoreData
import SwiftUI
import CloudKit
import ConfettiSwiftUI

class HomeViewModel : ObservableObject {
    @Published var challenges = [Challenge]()
    @Published var groups = [UserGroup]()
    @Published var user = User(record: CKRecord(recordType: "User"), usersRecordId: "", name: "", photo: nil, groups: [], notificationId: "")
    @Published var isUserLoading = true
    @Published var areChallengesLoading = true
    @Published var areGroupsLoading = true
    @Published var confetti = 0
    @Published var nextChallengeText = ""
    
    init() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadData()
        }
    }
    
    func triggerConfetti(group: UserGroup) {
        confetti += 1
    }
    
    func loadData() {
        Task {
            if !CloudKitHelper.shared.hasUser() {
                await getUser()
            }
            
            async let user: () = getUser()
            async let challenges: () = getChallenges()
            async let groups: () = getGroups()
            
            let _ = await (user, challenges, groups)
        }
    }
    
    func getUser() async {
        if let user = try? await CloudKitHelper.shared.getCurrentUser(forceSync: true) {
            DispatchQueue.main.async {
                self.user = user
                self.isUserLoading = false
            }
        }
    }
    
    func getChallenges() async {
        do {
            let challenges = try await CloudKitHelper.shared.getChallengesForUser(currentChallenges: challenges) ?? []
            
            DispatchQueue.main.async {
                self.challenges = challenges
                self.areChallengesLoading = false
                self.loadChallengeData()
            }
        } catch {
            print(error)
        }
    }
    
    func loadNextChallengeText() {
        guard let today = Calendar.current.dateComponents([.weekday], from: Date()).weekday else { return }
        
        var dayToCheck = today
        var dayToRun = today
        
        var groupsToRun = groups.filter({ $0.displayedDays.contains(today - 1) && ($0.deliveryTime.setDateToToday() ?? Date()) > Date() })
            
        var daysChecked = 1
        while(groupsToRun.isEmpty && daysChecked < 7) {
            if dayToCheck == 7 {
                dayToCheck = 1
            }
            else {
                dayToCheck += 1
            }
            
            groupsToRun = groups.filter({ $0.displayedDays.contains(dayToCheck - 1) })
            
            if !groupsToRun.isEmpty {
                dayToRun = dayToCheck
            }
            
            daysChecked += 1
        }
        
        if let nextGroupToRun = groupsToRun.sorted(by: { $0.deliveryTime < $1.deliveryTime }).first {
            var newText = ""
            if today == dayToRun {
                newText += "Your next challenge is today at "
            }
            else {
                newText += "Your next challenge is \(dayToRun.getWeekday()) at "
            }
            
            newText += "\(nextGroupToRun.deliveryTime.formatted(date: .omitted, time: .shortened)) for **\(nextGroupToRun.name)** \(nextGroupToRun.emoji)."
            
            nextChallengeText = newText
        }
        else {
            nextChallengeText = "No challenges scheduled. Create or join a group to get started!"
        }
    }
    
    func loadGroupData() {
        DispatchQueue.concurrentPerform(iterations: groups.count) { index in
            Task {
                async let users: () = getUsersForGroup(group: groups[index])
                async let activities: () = getActivitiesForGroup(group: groups[index])
                
                let _ = await [users, activities]
            }
        }
    }
    
    func getActivitiesForGroup(group: UserGroup) async {
        do {
            let currentActivities = group.activities
            let newActivities = try await CloudKitHelper.shared.getActivitiesForGroup(group: group) ?? []
                        
            if currentActivities.count != newActivities.count {
                let newActivityIds = newActivities.compactMap { $0.record.recordID }
                                
                let activitiesOnDeviceOnly = currentActivities.filter({ !newActivityIds.contains($0.record.recordID) })
                
                let newlyCreatedActivitiesOnDevice = activitiesOnDeviceOnly.filter({ (Calendar.current.date(byAdding: .minute, value: 2, to: $0.createdAt) ?? Date()) > Date() })
                
                // there is a delay in pulling down newly created cloudkit records.
                // this keeps them from disappearing temporarily
                DispatchQueue.main.async {
                    group.activities = (newActivities + newlyCreatedActivitiesOnDevice).sorted(by: { $0.name < $1.name })
                    group.areActivitiesLoading = false
                }
            }
            else {
                DispatchQueue.main.async {
                    group.activities = newActivities.sorted(by: { $0.name < $1.name })
                    group.areActivitiesLoading = false
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func getUsersForGroup(group: UserGroup) async {
        do {
            let currentUsers = group.users
            let newUsers = try await CloudKitHelper.shared.getUsersForGroup(group: group) ?? []
            
            if currentUsers.count != newUsers.count {
                let newUserIds = newUsers.compactMap { $0.usersRecordId }
                                
                let usersOnDeviceOnly = currentUsers.filter({ !newUserIds.contains($0.usersRecordId) })
                
                let newlyCreatedUsersOnDevice = usersOnDeviceOnly.filter({ (Calendar.current.date(byAdding: .minute, value: 2, to: $0.createdAt) ?? Date()) > Date() })
                
                // there is a delay in pulling down newly created cloudkit records.
                // this keeps them from disappearing temporarily
                
                DispatchQueue.main.async {
                    group.users = (newUsers + newlyCreatedUsersOnDevice).sorted(by: { $0.name < $1.name })
                }
            }
            else {
                DispatchQueue.main.async {
                    group.users = newUsers.sorted(by: { $0.name < $1.name })
                }
            }
            
            DispatchQueue.main.async {
                group.areUsersLoading = false
            }
        }
        catch {
            print(error)
        }
    }
    
    func loadChallengeData() {
        if challenges.allSatisfy({ $0.activity != nil && $0.group != nil && $0.users != nil }) {
            return
        }
        
        DispatchQueue.concurrentPerform(iterations: challenges.count) { index in
            CloudKitHelper.shared.getActivityFromChallenge(challenge: challenges[index]) { [weak self] activity in
                DispatchQueue.main.async {
                    if let challengeCopy = self?.challenges[index] {
                        challengeCopy.activity = activity
                        self?.challenges[index] = challengeCopy
                    }
                }
            }
            
            CloudKitHelper.shared.getGroupFromChallenge(challenge: challenges[index]) { [weak self] group in
                DispatchQueue.main.async {
                    if let challengeCopy = self?.challenges[index] {
                        challengeCopy.group = group
                        self?.challenges[index] = challengeCopy
                    }
                }
            }
            
            CloudKitHelper.shared.getUsersFromChallenge(challenge: challenges[index]) { [weak self] users in
                DispatchQueue.main.async {
                    if let challengeCopy = self?.challenges[index] {
                        challengeCopy.users = users
                        self?.challenges[index] = challengeCopy
                        self?.challenges[index].setStatus()
                    }
                }
            }
        }
    }
    
    func getGroups() {
        CloudKitHelper.shared.getGroupsForUser(currentGroups: groups) { [weak self] newGroups in
            if let newGroups = newGroups {
                DispatchQueue.main.async {
                    // This keeps details from blanking out while the new values are loaded
                    newGroups.forEach { group in
                        if let currentActivities = self?.groups.first(where: { $0.record.recordID == group.record.recordID })?.activities {
                            group.activities = currentActivities
                        }
                        
                        if let currentUsers = self?.groups.first(where: { $0.record.recordID == group.record.recordID })?.users {
                            group.users = currentUsers
                        }
                    }
                                        
                    if self?.groups.count != newGroups.count {
                        let newGroupIds = newGroups.compactMap { $0.record.recordID }
                        let groupsOnDeviceOnly = self?.groups.filter({ !newGroupIds.contains($0.record.recordID) })

                        let newlyCreatedGroupsOnDevice = groupsOnDeviceOnly?.filter({ (Calendar.current.date(byAdding: .minute, value: 2, to: $0.createdAt) ?? Date()) > Date() })

                        self?.groups = (newGroups + (newlyCreatedGroupsOnDevice ?? [])).sorted(by: { $0.name < $1.name })
                    }
                    else {
                        self?.groups = newGroups.sorted(by: { $0.name < $1.name })
                    }
                    
                    self?.areGroupsLoading = false
                    self?.loadGroupData()
                    self?.loadNextChallengeText()
                }
            }
        }
    }
}
