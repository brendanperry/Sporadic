//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/29/21.
//

import Foundation

struct Activity: Identifiable, Codable {
    var id: Int = 0
    var unit: Unit = Unit.MilesOrKilometers
    var name: String = "Default"
    var minValue: Float = 1
    var maxValue: Float = 10
    var total: Float = 0
    var isEnabled: Bool = false
}
