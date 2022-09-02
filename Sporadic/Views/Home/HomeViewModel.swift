//
//  HomeViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation
import CoreData
import SwiftUI

class HomeViewModel : ObservableObject {
    @Published var challenges: [Challenge]?
    @Published var groups: [UserGroup]?
    @Published var user: User?
    @Published var loadingStatus = LoadingStatus.loaded
    
    let cloudKitHelper: CloudKitHelper
//    let notificationHelper: NotificationHelper
    
    init(cloudKitHelper: CloudKitHelper) {
        self.cloudKitHelper = cloudKitHelper
//        self.notificationHelper = notificationHelper
        
        //dataHelper.resolveDuplicateActivities()
        
        //notificationHelper.scheduleAllNotifications(settingsChanged: false)
        
        loadData(forceSync: true)
    }
    
    func loadData(forceSync: Bool) {
        Task {
            await getChallenges()
            await getGroups(forceSync: forceSync)
        }
    }
    
    func getChallenges() async {
        DispatchQueue.main.async { [weak self] in
            Task {
                do {
                    self?.challenges = try await self?.cloudKitHelper.getChallengesForUser()
                } catch {
                    print(error)
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
                self?.groups = newGroups
                self?.loadingStatus = .loaded
            }
        }
        catch {
            DispatchQueue.main.async { [weak self] in
                self?.loadingStatus = .failed
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
