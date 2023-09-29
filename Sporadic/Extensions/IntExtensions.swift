//
//  IntExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/20/23.
//

import Foundation

extension Int {
    func getWeekday() -> String {
        if self == 1 {
            return "Sunday"
        }
        else if self == 2 {
            return "Monday"
        }
        else if self == 3 {
            return "Tuesday"
        }
        else if self == 4 {
            return "Wednesday"
        }
        else if self == 5 {
            return "Thursday"
        }
        else if self == 6 {
            return "Friday"
        }
        else if self == 7 {
            return "Saturday"
        }
        
        return ""
    }
}
