//
//  TextHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/12/21.
//

import SwiftUI
import Foundation

class TextHelper {
    static func text(key: String, alignment: Alignment, type: TextType, color: Color? = nil, prefix: String? = nil, suffix: String? = nil) -> some View {
        switch(type) {
        case .h1:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 29, relativeTo: .largeTitle))
                .foregroundColor(Color("Gray300")))
        case .h2:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 25, relativeTo: .title))
                .foregroundColor(color == nil ? Color("Gray300") : color))
        case .h3:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 19, relativeTo: .title2))
                .foregroundColor(color == nil ? Color("Gray300") : color))
        case .h4:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 17, relativeTo: .title3))
                .foregroundColor(color == nil ? Color("Gray300") : color))
        case .h5:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-SemiBold", size: 15, relativeTo: .title3))
                .foregroundColor(color == nil ? Color("Gray300") : color))
        case .h6:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 13, relativeTo: .caption))
                .foregroundColor(color == nil ? Color("ActivityLight") : color))
        case .h7:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 12, relativeTo: .caption2))
                .foregroundColor(color == nil ? Color("Gray200") : color))
        case .body:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Lexend-Regular", size: 15, relativeTo: .body))
                .foregroundColor(color == nil ? Color("Gray200") : color))
        }
    }
    
    private static func GetText(_ key: String, _ alignment: Alignment, _ prefix: String? = nil, _ suffix: String? = nil) -> some View {
        return Text(.init((prefix ?? "") + Localize.getString(key) + (suffix ?? "")))
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
        
enum TextType {
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    case h7
    case body
}
