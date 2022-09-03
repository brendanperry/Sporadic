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
//    let notificationHelper: NotificationHelper
    
    init(cloudKitHelper: CloudKitHelper) {
        self.cloudKitHelper = cloudKitHelper
//        self.notificationHelper = notificationHelper
        
        //dataHelper.resolveDuplicateActivities()
        
        //notificationHelper.scheduleAllNotifications(settingsChanged: false)
        
        loadData(forceSync: false)
    }
    
    func loadData(forceSync: Bool) {
        Task {
            await getUser()
            await getChallenges(forceSync: forceSync)
            await getGroups(forceSync: forceSync)
        }
    }
    
    func getUser() async {
        DispatchQueue.main.async { [weak self] in
            Task {
                if let user = try? await self?.cloudKitHelper.currentUser {
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
                    self?.loadChallengeData()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func loadChallengeData() {
        for i in 0..<challenges.count {
            cloudKitHelper.getActivityFromChallenge(challenge: challenges[i]) { [weak self] activity in
                DispatchQueue.main.async {
                    self?.challenges[i].activity = activity
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
