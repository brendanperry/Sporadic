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
    
    init(group: UserGroup) {
        self.group = group
    }
}
