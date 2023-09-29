//
//  DaysForChallenge.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/16/23.
//

import Foundation


enum DaysForChallenge: Int, CustomStringConvertible, CaseIterable {
    case sunday = 0, monday = 1, tuesday = 2, wednesday = 3, thursday = 4, friday = 5, saturday = 6
    
    var description: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}
