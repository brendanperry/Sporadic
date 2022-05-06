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
    let dataHelper: Repository
    let notificationHelper: NotificationHelper
    
    init(dataHelper: Repository, notificationHelper: NotificationHelper) {
        self.dataHelper = dataHelper
        self.notificationHelper = notificationHelper
        
        notificationHelper.scheduleAllNotifications(settingsChanged: false)
    }
    
    func completeChallenge() {
        dataHelper.saveChanges()
        GlobalSettings.Env.currentChallenge?.oneChallengeToOneActivity?.total += GlobalSettings.Env.currentChallenge?.total ?? 0
        GlobalSettings.Env.updateStatus()
    }
    
    func getActivityCount() -> Int {
        return dataHelper.fetchActiveActivities()?.count ?? 0
    }
    
    func getNotificationStatus(completion: @escaping(Bool) -> Void) {
        notificationHelper.getNotificationStatus(completion: completion)
    }
}
