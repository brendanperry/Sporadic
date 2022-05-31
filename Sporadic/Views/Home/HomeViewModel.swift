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
    
    let cloudKitHelper: CloudKitHelper
    let notificationHelper: NotificationHelper
    
    init(cloudKitHelper: CloudKitHelper, notificationHelper: NotificationHelper) {
        self.cloudKitHelper = cloudKitHelper
        self.notificationHelper = notificationHelper
        
        //dataHelper.resolveDuplicateActivities()
        
        //notificationHelper.scheduleAllNotifications(settingsChanged: false)
    }
    
    func getUser() async {
        do {
            user = try await cloudKitHelper.getUserRecord()
        } catch {
            print("Could not get challenges")
        }
    }
    
    func getChallenges() async {
        do {
            challenges = try await cloudKitHelper.getChallengesForUser()
        } catch {
            print("Could not get challenges")
        }
    }
        
    func getGroups() async {
        do {
            groups = try await cloudKitHelper.getGroupsForUser()
        } catch {
            print("Could not get challenges")
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
