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
    @Published var user = User(record: CKRecord(recordType: "User"), usersRecordId: "", name: "challenger", photo: nil, groups: [])
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
            if group.name == "Bark 1" {
                let currentActivities = group.activities
                let newActivities = try await CloudKitHelper.shared.getActivitiesForGroup(group: group) ?? []
                
                if currentActivities.count != newActivities.count {
                    let newActivityIds = newActivities.compactMap { $0.recordId }
                    
                    print(newActivityIds)
                    
                    let activitiesOnDeviceOnly = currentActivities.filter({ !newActivityIds.contains($0.recordId ?? CKRecord.ID(recordName: "Activity")) })
                    
                    let newlyCreatedActivitiesOnDevice = activitiesOnDeviceOnly.filter({ (Calendar.current.date(byAdding: .minute, value: 2, to: $0.createdAt) ?? Date()) > Date() })
                    
                    // there is a delay in pulling down newly created cloudkit records.
                    // this keeps them from disappearing temporarily
                    group.activities = newActivities + newlyCreatedActivitiesOnDevice
                }
                else {
                    group.activities = newActivities
                }
                
                group.areActivitiesLoading = false
            }
        }
        catch {
            print(error)
        }
    }
    
    func getUsersForGroup(group: UserGroup) async {
        do {
            group.users = try await CloudKitHelper.shared.getUsersForGroup(group: group) ?? []
            group.areUsersLoading = false
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
                    let currentGroups = self?.groups
                    
                    // This keeps activities from blanking out while the new values are loaded
                    var groups = newGroups
                    groups.forEach { group in
                        if let currentActivities = currentGroups?.first(where: { $0.record.recordID == group.record.recordID })?.activities {
                            group.activities = currentActivities
                        }
                    }
                    
                    self?.groups = groups
                    self?.areGroupsLoading = false
                    self?.loadGroupData()
                }
            }
        }
    }
}
