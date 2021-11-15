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
    var minValue: Float = 1
    var maxValue: Float = 5
    var total: Float = 0
    var isEnabled: Bool = false
}
