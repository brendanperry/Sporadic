//
//  ActivityTemplate.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation

struct ActivityTemplate: Identifiable {
    let id: Int
    let name: String
    let minValue: Double
    let maxValue: Double
    let selectedMin: Double
    let selectedMax: Double
    let minRange: Double
    let unit: ActivityUnit
    let category: ActivityCategory
}
