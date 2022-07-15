//
//  GroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import Foundation

class GroupOverviewViewModel: ObservableObject {
    @Published var days = 3
    @Published var time = Date()
    @Published var group: UserGroup
    @Published var daysInTheWeek = ["Su", "Tu"]
    @Published var activities = [Activity]()
    @Published var users = [User]()
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    
    init(group: UserGroup) {
        self.group = group
    }
    
    func getActivities() async {
        do {
            let activities = try await CloudKitHelper.shared.getActivitiesForGroup(group: group) ?? []
            
            DispatchQueue.main.async {
                self.activities = activities
            }
        }
        catch {
            print(error)
            DispatchQueue.main.async {
                self.errorMessage = "Could not load group activities."
                self.showError = true
            }
        }
    }
    
    func getUsers() async {
        do {
            let users = try await CloudKitHelper.shared.getUsersForGroup(group: group) ?? []
            
            DispatchQueue.main.async {
                self.users = users
            }
        }
        catch {
            print(error)
            DispatchQueue.main.async {
                self.errorMessage = "Could not load group users."
                self.showError = true
            }
        }
    }
    
    func deleteGroup(completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        CloudKitHelper.shared.deleteGroup(recordId: group.recordId) { [weak self] error in
            DispatchQueue.main.async {
                if let _ = error {
                    self?.errorMessage = "Could not delete group. Please check your connection and try again."
                    self?.showError = true
                    completion(false)
                }
                else {
                    completion(true)
                }
                
                self?.isLoading = false
            }
        }
    }
}
