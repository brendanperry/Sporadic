//
//  SettingsViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation

class SettingsViewModel : ObservableObject {
//    let notificationHelper: NotificationHelper
    @Published var showDisabledAlert = false
    @Published var showEnabledAlert = false
    
//    init(notificationHelper: NotificationHelper) {
//        self.notificationHelper = notificationHelper
//    }
    
    func scheduleNotifications(settingsChanged: Bool) {
        DispatchQueue.main.async { [weak self] in
//            self?.notificationHelper.scheduleAllNotifications(settingsChanged: settingsChanged)
        }
    }
}
