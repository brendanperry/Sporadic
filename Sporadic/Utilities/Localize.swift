//
//  Localize.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/30/21.
//

import Foundation

// Localization done in Localizable.strings file
struct Localize {
    static func getString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
