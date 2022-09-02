//
//  SettingsViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation
import CloudKit

class SettingsViewModel : ObservableObject {
//    let notificationHelper: NotificationHelper
    @Published var showDisabledAlert = false
    @Published var showEnabledAlert = false
    @Published var user = User(recordId: CKRecord.init(recordType: "User").recordID, usersRecordId: "", name: "")
    @Published var showError = false
    
    var errorMessage = ""

    
//    init(notificationHelper: NotificationHelper) {
//        self.notificationHelper = notificationHelper
//    }
    
    init() {
        Task {
            do {
                user = try await CloudKitHelper.shared.currentUser ?? user
            }
            catch {
                print(error)
            }
        }
    }
    
    func updateUser() {
        CloudKitHelper.shared.updateUser(user: user) { [weak self] error in
            if let _ = error {
                self?.errorMessage = "We could not save the changes to your user profile. Please check your connection and try again."
            }
        }
    }
    
    func scheduleNotifications(settingsChanged: Bool) {
        DispatchQueue.main.async { [weak self] in
//            self?.notificationHelper.scheduleAllNotifications(settingsChanged: settingsChanged)
        }
    }
}
