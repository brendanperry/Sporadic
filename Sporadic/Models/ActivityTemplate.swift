//
//  ActivityTemplate.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation
import SwiftUI

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
    let requiresEquipment: Bool
    let canDoIndoors: Bool

    var color: Color {
        if category == .cardio {
            return Color("Cardio")
        }
        else if category == .strength {
            return Color("Strength")
        }
        else {
            return Color("CustomExercise")
        }
    }
}
