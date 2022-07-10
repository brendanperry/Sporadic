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
    let notificationHelper: NotificationHelper
    
    init(cloudKitHelper: CloudKitHelper, notificationHelper: NotificationHelper) {
        self.cloudKitHelper = cloudKitHelper
        self.notificationHelper = notificationHelper
        
        //dataHelper.resolveDuplicateActivities()
        
        //notificationHelper.scheduleAllNotifications(settingsChanged: false)
    }
    
    func getChallenges() async {
        do {
            challenges = try await cloudKitHelper.getChallengesForUser()
        } catch {
            print(error)
        }
    }
    
    func getGroups() async {
        loadingStatus = .loading
        
        do {
            let newGroups = try await cloudKitHelper.getGroupsForUser()
            
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
