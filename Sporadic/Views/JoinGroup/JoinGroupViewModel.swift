//
//  JoinGroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/17/22.
//

import Foundation
import CloudKit


class JoinGroupViewModel: ObservableObject {
    let groupId: String
    let homeViewModel: HomeViewModel
    @Published var group: UserGroup?
    @Published var isLoading = true
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var users = [User]()
    
    init(groupId: String, homeViewModel: HomeViewModel) {
        self.groupId = groupId
        self.homeViewModel = homeViewModel
        
        getGroup()
    }
    
    func joinGroup(completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        if let group = group {
            CloudKitHelper.shared.addUserToGroup(group: group) { [weak self] updatedGroup in
                DispatchQueue.main.async {
                    if let updatedGroup = updatedGroup {
                        self?.homeViewModel.groups.append(updatedGroup)
                        completion(true)
                    }
                    else {
                        self?.errorMessage = "Failed to join group. Please check your connection and try again."
                        self?.showError = true
                    }
                    
                    self?.isLoading = false
                }
            }
        }
    }
    
    func getGroup() {
        let recordId = CKRecord.ID(recordName: groupId)
        
        CloudKitHelper.shared.getGroup(byId: recordId) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.description
                    self?.showError = true
                }
            case .success(let loadedGroup):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.group = loadedGroup
                }
            }
        }
    }
}
