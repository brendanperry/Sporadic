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

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}
