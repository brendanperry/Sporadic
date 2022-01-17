//
//  colorSchemeHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/15/22.
//

import SwiftUI

class ColorSchemeHelper {
    @AppStorage(UserPrefs.appearance.rawValue)
    var appTheme = "System"
    
    func getColorSceme() -> ColorScheme? {
        if appTheme == "Light" {
            return .light
        }

        if appTheme == "Dark" {
            return .dark
        }

        return nil
    }
}
