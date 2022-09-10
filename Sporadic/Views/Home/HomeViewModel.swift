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
    @Published var user = User(recordId: CKRecord(recordType: "User").recordID, usersRecordId: "", name: "challenger", photo: nil)
    @Published var loadingStatus = LoadingStatus.loaded
    @Published var isUserLoading = true
    @Published var areChallengesLoading = true
    @Published var areGroupsLoading = true
    
    let cloudKitHelper: CloudKitHelper
    
    init(cloudKitHelper: CloudKitHelper) {
        self.cloudKitHelper = cloudKitHelper
        
        loadData(forceSync: false)
    }
    
    func loadData(forceSync: Bool) {
        Task {
            await getUser(forceSync: forceSync)
            await getChallenges(forceSync: forceSync)
            await getGroups(forceSync: forceSync)
        }
    }
    
    func getUser(forceSync: Bool) async {
        DispatchQueue.main.async { [weak self] in
            Task {
                if let user = try? await self?.cloudKitHelper.getCurrentUser(forceSync: forceSync) {
                    self?.user = user
                    self?.isUserLoading = false
                }
            }
        }
    }
    
    func getChallenges(forceSync: Bool = false) async {
        DispatchQueue.main.async { [weak self] in
            Task {
                do {
                    self?.challenges = try await self?.cloudKitHelper.getChallengesForUser(forceSync: forceSync) ?? []
                    self?.areChallengesLoading = false
                    self?.loadChallengeData(forceSync: forceSync)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func loadChallengeData(forceSync: Bool) {
        for i in 0..<challenges.count {
            cloudKitHelper.getActivityFromChallenge(forceSync: forceSync, challenge: challenges[i]) { [weak self] activity in
                DispatchQueue.main.async {
                    self?.challenges[i].activity = activity
                }
            }
            
            cloudKitHelper.getGroupFromChallenge(forceSync: forceSync, challenge: challenges[i]) { [weak self] group in
                DispatchQueue.main.async {
                    self?.challenges[i].group = group
                }
            }
            
            cloudKitHelper.getUsersFromChallenge(forceSync: forceSync, challenge: challenges[i]) { [weak self] users in
                DispatchQueue.main.async {
                    self?.challenges[i].users = users
                }
            }
        }
    }
    
    func getGroups(forceSync: Bool = false) async {
        DispatchQueue.main.async { [weak self] in
            self?.loadingStatus = .loading
        }
        
        do {
            let newGroups = try await cloudKitHelper.getGroupsForUser(forceSync: forceSync)
            
            DispatchQueue.main.async { [weak self] in
                self?.groups = newGroups ?? []
                self?.loadingStatus = .loaded
                self?.areGroupsLoading = false
            }
        }
        catch {
            DispatchQueue.main.async { [weak self] in
                self?.loadingStatus = .failed
                self?.areGroupsLoading = false
            }
            
            print(error)
        }
    }

func completeChallenge() {
    //        GlobalSettings.Env.currentChallenge?.activity?.total += GlobalSettings.Env.currentChallenge?.total ?? 0
    //        GlobalSettings.Env.updateStatus()
}

//    func getActivityCount() -> Int {
//        return dataHelper.fetchActiveActivities()?.count ?? 0
//    }

func getNotificationStatus(completion: @escaping(Bool) -> Void) {
    //        notificationHelper.getNotificationStatus(completion: completion)
}
}
