//
//  TextHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/12/21.
//

import SwiftUI
import Foundation

class TextHelper {
    func GetTextByType(key: String, alignment: Alignment, type: TextType, color: Color? = nil, prefix: String? = nil, suffix: String? = nil) -> some View {
        switch(type) {
        case .h1:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 28, relativeTo: .largeTitle))
                .foregroundColor(Color("Header")))
        case .h2:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 14, relativeTo: .title))
                .foregroundColor(color == nil ? Color("Header") : color))
        case .h3:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 18, relativeTo: .title2))
                .foregroundColor(Color("Header")))
        case .h4:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 11, relativeTo: .title3))
                .foregroundColor(Color("Header")))
        case .body:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .body))
                .foregroundColor(color == nil ? Color("Body") : color))
        case .challengeAndSettings:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 18, relativeTo: .title3))
                .foregroundColor(color == nil ? Color("Header") : color))
        case .challengeGroup:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 12, relativeTo: .footnote))
                .foregroundColor(Color("Body")))
        case .activityTitle:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 23, relativeTo: .largeTitle))
                .foregroundColor(color == nil ? Color("Header") : color))
        }
    }
    
    private func GetText(_ key: String, _ alignment: Alignment, _ prefix: String? = nil, _ suffix: String? = nil) -> some View {
        return Text((prefix ?? "") + Localize.getString(key) + (suffix ?? ""))
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
        
enum TextType {
    case h1
    case h2
    case h3
    case h4
    case body
    case challengeAndSettings
    case challengeGroup
    case activityTitle
}
