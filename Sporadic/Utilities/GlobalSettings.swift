//
//  Environment.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/6/22.
//

import Foundation
import CoreData
import UserNotifications

public class GlobalSettings: ObservableObject {
    public static var Env = GlobalSettings()
    
    @Published var currentChallenge: Challenge?
    @Published var showWarning = false
    
    let dataHelper = DataController.shared
    let notificationHelper = NotificationHelper(dataHelper: DataController.shared)
    
    private init() { }
    
    func updateStatus() {
        DispatchQueue.main.async { [weak self] in
            self?.currentChallenge = self?.getDailyActivity()
        }
        
        self.notificationHelper.getNotificationStatus { isAuthorized in
            DispatchQueue.main.async { [weak self] in
                self?.showWarning = self?.dataHelper.getTotalChallengesScheduled() == 0 || !isAuthorized
            }
        }
    }
    
    func getDailyActivity() -> Challenge? {
        return dataHelper.fetchCurrentChallenge()
    }
    
    func scheduleNotificationsIfNoneExist() {
        if dataHelper.getTotalChallengesScheduled() == 0 {
            notificationHelper.scheduleAllNotifications(settingsChanged: false)
        }
        
        updateStatus()
    }
}
