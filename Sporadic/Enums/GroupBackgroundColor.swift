//
//  GroupBackgroundColor.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import SwiftUI

enum GroupBackgroundColor: Int, CaseIterable {
    case one, two, three, four, five, six, seven, eight
}

extension GroupBackgroundColor {
    func getColor() -> Color {
        switch self {
        case .one:
            return Color("GroupOption1")
        case .two:
            return Color("GroupOption2")
        case .three:
            return Color("GroupOption3")
        case .four:
            return Color("GroupOption4")
        case .five:
            return Color("GroupOption5")
        case .six:
            return Color("GroupOption6")
        case .seven:
            return Color("GroupOption7")
        case .eight:
            return Color("GroupOption8")
        }
    }
}
