//
//  DoubleExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        return String(formatter.string(from: number) ?? "")
    }
}
