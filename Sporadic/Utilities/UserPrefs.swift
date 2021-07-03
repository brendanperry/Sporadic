//
//  UserPrefs.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/3/21.
//

import Foundation

enum UserPrefs: String, Codable {
    case DaysPerWeek
    case DeliveryDate
    case Appearance
    case UseMetricUnits
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
