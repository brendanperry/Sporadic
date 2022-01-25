//
//  SettingsViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation

class SettingsViewModel : ObservableObject {
    let notificationHelper: NotificationHelper
    
    init(notificationHelper: NotificationHelper) {
        self.notificationHelper = notificationHelper
    }
    
    func scheduleNotifications() {
        notificationHelper.scheduleAllNotifications()
    }
}
