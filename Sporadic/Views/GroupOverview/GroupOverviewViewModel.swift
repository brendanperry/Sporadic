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
        }
    }
}
