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
    
    var timer = Timer()
    
    init() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadData()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            DispatchQueue.global(qos: .userInitiated).async {
                self.loadData()
            }
        })
    }
    
    func loadData() {
        Task {
            if !CloudKitHelper.shared.hasUser() {
                await getUser()
            }
            
            async let challenges: () = getChallenges()
            async let groups: () = getGroups()
            
            let _ = await (challenges, groups)
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
    
    For Friday: add dummy loading indicator to group activities, this may suck because we will have to manually track when they have been loaded since we h
    can't save them as null before hand
    
    Then you need to let people complete challenges and poll for updates on that as well
    
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
            group.activities = try await CloudKitHelper.shared.getActivitiesForGroup(group: group) ?? []
        }
        catch {
            print(error)
        }
    }
    
    func getUsersForGroup(group: UserGroup) async {
        do {
            group.users = try await CloudKitHelper.shared.getUsersForGroup(group: group) ?? []
        }
        catch {
            print(error)
        }
    }
    
    func loadChallengeData() {
        // TODO: split this up because we will want to constantly check for new people to have completed challenges
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
        CloudKitHelper.shared.getGroupsForUser(currentGroups: groups) { [weak self] groups in
            if let groups = groups {
                DispatchQueue.main.async {
                    self?.groups = groups
                    self?.areGroupsLoading = false
                    self?.loadGroupData()
                }
            }
        }
    }
}
