//
//  ActivityCategory.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/4/23.
//

import Foundation


enum ActivityCategory: String, CaseIterable, Identifiable {
    var id: RawValue { rawValue }
    
    case cardio = "Cardio", strength = "Strength", custom = "Custom"
}
