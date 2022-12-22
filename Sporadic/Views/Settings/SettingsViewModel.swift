//
//  SettingsViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation
import CloudKit
import UIKit

class SettingsViewModel : ObservableObject {
    @Published var showDisabledAlert = false
    @Published var showEnabledAlert = false
    @Published var photo: UIImage?
    @Published var name = ""
    @Published var showError = false
    
    var errorMessage = ""
    var user: User? = nil
    var imageTaskId: UIBackgroundTaskIdentifier?
    var nameTaskId: UIBackgroundTaskIdentifier?
    
    init() {
        Task {
            await loadUserSettings()
        }
    }
    
    func loadUserSettings() async {
        user = try? await CloudKitHelper.shared.getCurrentUser(forceSync: false)
        
        DispatchQueue.main.async {
            self.photo = self.user?.photo
            self.name = self.user?.name ?? ""
        }
    }
    
    func updateUserName() {
        guard let user = user else {
            return
        }
        
        user.name = name

        DispatchQueue.global().async {
            self.imageTaskId = UIApplication.shared.beginBackgroundTask (withName: "Update user name") {
                if let backgroundTaskID = self.nameTaskId {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                }
                
                self.nameTaskId = UIBackgroundTaskIdentifier.invalid
            }
            
            CloudKitHelper.shared.updateUserName(user: user) { [weak self] error in
                if let _ = error {
                    self?.errorMessage = "We could not save the changes to your user profile. Please check your connection and try again."
                    self?.showError = true
                }
                
                if let backgroundTaskID = self?.nameTaskId {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                }

                self?.nameTaskId = UIBackgroundTaskIdentifier.invalid
            }
        }
    }
    
    func updateUserImage() {
        guard let user = user else {
            return
        }
        
        let photo = photo?.orientedUp()
        
        user.photo = photo
        
        DispatchQueue.global().async {
            self.imageTaskId = UIApplication.shared.beginBackgroundTask (withName: "Update user image") {
                if let backgroundTaskID = self.imageTaskId {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                }
                
                self.imageTaskId = UIBackgroundTaskIdentifier.invalid
            }
            
            CloudKitHelper.shared.updateUserImage(user: user) { [weak self] error in
                if let _ = error {
                    self?.errorMessage = "We could not save the changes to your user profile. Please check your connection and try again."
                    self?.showError = true
                }
                
                if let backgroundTaskID = self?.imageTaskId {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                }

                self?.imageTaskId = UIBackgroundTaskIdentifier.invalid
            }
        }
    }
}
