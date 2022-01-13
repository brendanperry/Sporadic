//
//  ButtonExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

extension Button {
    func withSettingsButtonStyle() -> some View {
        self.frame(width: 60)
        .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
        .foregroundColor(Color("SettingButtonTextColor"))
        .padding(12)
        .background(Color("SettingsButtonBackgroundColor"))
        .cornerRadius(10)
    }
}
