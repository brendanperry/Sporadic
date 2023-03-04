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

class HomeViewModel : ObservableObject {
    @Published var challenges = [Challenge]()
    @Published var groups = [UserGroup]()
    @Published var user = User(record: CKRecord(recordType: "User"), usersRecordId: "", name: "", photo: nil, groups: [])
    @Published var isUserLoading = true
    @Published var areChallengesLoading = true
    @Published var areGroupsLoading = true
        
    init() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadData()
        }
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
                    group.activities = newActivities + newlyCreatedActivitiesOnDevice
                }
            }
            else {
                DispatchQueue.main.async {
                    group.activities = newActivities
                }
            }
            
            DispatchQueue.main.async {
                group.areActivitiesLoading = false
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
                    group.users = newUsers + newlyCreatedUsersOnDevice
                }
            }
            else {
                DispatchQueue.main.async {
                    group.users = newUsers
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
        if challenges.allSatisfy({ $0.activity != nil && $0.group != nil && !$0.users.isEmpty }) {
            return
        }
        
        DispatchQueue.concurrentPerform(iterations: challenges.count) { index in
            CloudKitHelper.shared.getActivityFromChallenge(challenge: challenges[index]) { [weak self] activity in
                DispatchQueue.main.async {
                    self?.challenges[index].activity = activity
                }
            }
            
            CloudKitHelper.shared.getGroupFromChallenge(challenge: challenges[index]) { [weak self] group in
                DispatchQueue.main.async {
                    self?.challenges[index].group = group
                }
            }
            
            CloudKitHelper.shared.getUsersFromChallenge(challenge: challenges[index]) { [weak self] users in
                DispatchQueue.main.async {
                    self?.challenges[index].users = users
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

                        self?.groups = newGroups + (newlyCreatedGroupsOnDevice ?? [])
                    }
                    else {
                        self?.groups = newGroups
                    }
                    
                    self?.areGroupsLoading = false
                    self?.loadGroupData()
                }
            }
        }
    }
}
