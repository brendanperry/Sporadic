//
//  UserPrefs.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/3/21.
//

import Foundation
import SwiftUI

enum UserPrefs: String, Codable {
    case daysPerWeek
    case deliveryTime
    case appearance
    case measurement
    case streak
}
