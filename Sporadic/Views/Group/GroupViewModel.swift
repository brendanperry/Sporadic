//
//  GroupViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import Foundation

class GroupViewModel: ObservableObject {
    @Published var days = 3
    @Published var time = Date()
    
    init() {
        
    }
}
