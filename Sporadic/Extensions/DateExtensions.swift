//
//  DateExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import Foundation

extension Date {
    private static let formatter = ISO8601DateFormatter()

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
    
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func setDateToToday() -> Date? {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        
        guard let hour = components.hour, let minute = components.minute, let second = components.second else { return nil }
        
        let d = Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: Date())
        
        return d
    }
    
    func nearest30Minutes() -> Date {
        let cal = Calendar.current
        let minutes = cal.component(.minute, from: self)
        let roundedMinutes = lrint(Double(minutes) / 30) * 30
        return cal.date(byAdding: .minute, value: roundedMinutes - minutes, to: self) ?? self
    }
}
