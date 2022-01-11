//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/29/21.
//

import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id: Int = 0
    var name: String = "Run"
    var minValue: Double = 1
    var maxValue: Double = 5
    var total: Double = 0
    var isEnabled: Bool = false
}
