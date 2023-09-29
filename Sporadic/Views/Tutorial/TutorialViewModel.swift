//
//  TutorialViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/30/23.
//

import Foundation
import CloudKit
import UIKit
import SwiftUI

class TutorialViewModel: ObservableObject {
    @Published var selectedDifficulty = GroupDifficulty.beginner
    @Published var name = ""
    @Published var photo: UIImage? = nil
    @Published var group = UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "Group Deleted", owner: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"))
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var selection = 0
    @Published var isLoading = false

    
    func updateUser() {
        guard let user = CloudKitHelper.shared.getCachedUser() else {
            errorMessage = "No iCloud account was detected. Please make sure you are signed into your iCloud account and have an internet connection. Once this is done, restart the app and try again."
            showError = true
            isLoading = false
            
            return
        }
        
        user.name = name
        user.photo = photo
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        CloudKitHelper.shared.updateUserName(user: user) { [weak self] error in
            if let error {
                print(error)
                
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to update nickname. Please check your connection an try again."
                    self?.showError = true
                    self?.isLoading = false
                }
            }
            else {
                CloudKitHelper.shared.updateUserImage(user: user) { error in
                    if let error {
                        print(error)
                        
                        DispatchQueue.main.async {
                            self?.errorMessage = "Failed to update photo. Please check your connection an try again."
                            self?.showError = true
                            self?.isLoading = false
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            withAnimation {
                                self?.selection += 1
                            }
                        }
                    }
                }
            }
        }
    }
}
