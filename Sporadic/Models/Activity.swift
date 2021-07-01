//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/29/21.
//

import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id = UUID()
    
    var unit: Unit
    
    var name: String
    
    var minValue: Float
    
    var maxValue: Float
    
    var total: Float
    
    var isEnabled: Bool
}
