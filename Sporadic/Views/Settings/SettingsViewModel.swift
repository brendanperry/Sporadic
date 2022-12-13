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
    @Published var photo: UIImage? {
        didSet {
            updateUserImage()
        }
    }
    @Published var name = ""
    @Published var showError = false
    
    var errorMessage = ""
    var user: User? = nil

    init() {
        Task {
            do {
                user = try await CloudKitHelper.shared.getCurrentUser(forceSync: false)
                
                photo = user?.photo
                name = user?.name ?? ""
            }
            catch {
                print(error)
            }
        }
    }
    
    func updateUserName() {
        guard let user = user else {
            return
        }
        
        user.name = name

        CloudKitHelper.shared.updateUserName(user: user) { [weak self] error in
            if let _ = error {
                self?.errorMessage = "We could not save the changes to your user profile. Please check your connection and try again."
            }
        }
    }
    
    func updateUserImage() {
        guard let user = user else {
            return
        }
        
        user.photo = photo
        
        CloudKitHelper.shared.updateUserImage(user: user) { [weak self] error in
            if let _ = error {
                self?.errorMessage = "We could not save the changes to your user profile. Please check your connection and try again."
            }
        }
    }
}
