//
//  ActivityUnit.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import Foundation

enum ActivityUnit: String, CaseIterable {
    case miles = "miles"
    case minutes = "minutes"
    case seconds = "seconds"
    case laps = "laps"
    case sets = "sets"
    case general = "general"
}

extension ActivityUnit {
    func toString() -> String {
        switch self {
        case .miles: return Localize.getString("Miles")
        case .minutes: return Localize.getString("Minutes")
        case .seconds: return Localize.getString("Seconds")
        case .laps: return Localize.getString("Laps")
        case .sets: return Localize.getString("Sets")
        case .general: return Localize.getString("General")
        }
    }
    
    func toAbbreviatedString() -> String {
        switch self {
        case .miles: return Localize.getString("MilesAbbr")
        case .minutes: return Localize.getString("MinutesAbbr")
        case .seconds: return Localize.getString("SecondsAbbr")
        case .laps: return Localize.getString("Laps")
        case .sets: return Localize.getString("Sets")
        case .general: return Localize.getString("General")
        }
    }
    
    func defaultMin() -> Double {
        switch self {
        case .miles: return 1.0
        case .minutes: return 1
        case .seconds: return 30
        case .laps: return 1
        case .sets: return 3
        case .general: return 10
        }
    }
    
    func defaultMax() -> Double {
        switch self {
        case .miles: return 3.0
        case .minutes: return 5
        case .seconds: return 90
        case .laps: return 5
        case .sets: return 5
        case .general: return 100
        }
    }
    
    func minValue() -> Double {
        switch self {
        case .miles: return 0.25
        case .minutes: return 0.5
        case .seconds: return 1
        case .laps: return 1
        case .sets: return 1
        case .general: return 0.25
        }
    }
    
    func maxValue() -> Double {
        switch self {
        case .miles: return 20
        case .minutes: return 360
        case .seconds: return 120
        case .laps: return 50
        case .sets: return 50
        case .general: return 500
        }
    }
}
