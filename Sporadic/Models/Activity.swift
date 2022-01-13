//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/29/21.
//

import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id: Int = 0
    var name: String = "DEFAULT"
    var pastTense: String = "run"
    var presentTense: String = "running"
    var unit: String = "miles"
    var unitAbbreviation: String = "mi"
    var minValue: Double = 1
    var maxValue: Double = 100
    var minRange: Double = 0.25
    var selectedMin: Double = 1
    var selectedMax: Double = 50
    var total: Double = 0
    var isEnabled: Bool = false
}
