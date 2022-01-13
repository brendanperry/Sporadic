//
//  DateExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import Foundation

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}
