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
    @Published var loadingStatus = LoadingStatus.loaded
    @Published var isUserLoading = true
    @Published var areChallengesLoading = true
    @Published var areGroupsLoading = true
    
    let cloudKitHelper: CloudKitHelper
    
    init(cloudKitHelper: CloudKitHelper) {
        self.cloudKitHelper = cloudKitHelper
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadData(forceSync: false)
        }
    }
    
    func loadData(forceSync: Bool) {
        Task {
            await getUser()
            
            async let challenges: () = getChallenges(forceSync: forceSync)
            async let groups: () = getGroups(forceSync: forceSync)
            
            let _ = await (challenges, groups)
        }
    }
    
    func getUser() async {
        if let user = try? await cloudKitHelper.getCurrentUser(forceSync: true) {
            DispatchQueue.main.async {
                self.user = user
                self.isUserLoading = false
            }
        }
    }
    
    func getChallenges(forceSync: Bool = false) async {
        do {
            let challenges = try await cloudKitHelper.getChallengesForUser() ?? []
            
            DispatchQueue.main.async {
                self.challenges = challenges
                self.areChallengesLoading = false
                self.loadChallengeData()
            }
        } catch {
            print(error)
        }
    }
    
    func loadChallengeData() {
        DispatchQueue.concurrentPerform(iterations: challenges.count) { index in
            cloudKitHelper.getActivityFromChallenge(challenge: challenges[index]) { [weak self] activity in
                DispatchQueue.main.async {
                    self?.challenges[index].activity = activity
                }
            }
            
            cloudKitHelper.getGroupFromChallenge(challenge: challenges[index]) { [weak self] group in
                DispatchQueue.main.async {
                    self?.challenges[index].group = group
                }
            }
            
            cloudKitHelper.getUsersFromChallenge(challenge: challenges[index]) { [weak self] users in
                DispatchQueue.main.async {
                    self?.challenges[index].users = users
                }
            }
        }
    }
    
    func getGroups(forceSync: Bool = false) async {
        DispatchQueue.main.async { [weak self] in
            self?.loadingStatus = .loading
        }
        
        cloudKitHelper.getGroupsForUser { groups in
            if let groups = groups {
                DispatchQueue.main.async {
                    self.groups = groups
                    self.loadingStatus = .loaded
                    self.areGroupsLoading = false
                }
            }
            else {
                DispatchQueue.main.async {
                    self.loadingStatus = .failed
                    self.areGroupsLoading = false
                }
            }
        }
    }
}
