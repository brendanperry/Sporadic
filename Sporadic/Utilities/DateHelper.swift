//
//  DateHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/28/21.
//

import Foundation

class DateHelper {
    let dateFormatter = DateFormatter()

    func getFormattedDate(date: Date) -> String {
        dateFormatter.dateFormat = "h:mm a"

        return dateFormatter.string(from: date)
    }

    func getTime(date: Date) -> String {
        dateFormatter.dateFormat = "h:mm a"

        return dateFormatter.string(from: date)
    }

    func getHoursAndMinutes(date: Date) -> String {
        dateFormatter.dateFormat = "h:mm"

        return dateFormatter.string(from: date)
    }

    func getAmPm(date: Date) -> String {
        dateFormatter.dateFormat = "a"

        return dateFormatter.string(from: date)
    }
}
