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
        case TextType.largeTitle:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
                .foregroundColor(color == nil ? Color("LooksLikeBlack") : color))
        case TextType.title:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Gilroy", size: 32, relativeTo: .title))
                .foregroundColor(color == nil ? Color("LooksLikeBlack") : color))
        case TextType.medium:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .subheadline))
                .foregroundColor(color == nil ? Color("SubHeadingColor") : color))
        case .body:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .lineSpacing(5)
                .font(Font.custom("Gilroy-Medium", size: 16, relativeTo: .body))
                .foregroundColor(color == nil ? Color(UIColor.lightGray) : color))
        case .settingsEntryTitle:
            return AnyView(GetText(key, alignment, prefix, suffix)
                .font(Font.custom("Gilroy", size: 18, relativeTo: .title3)))
        }
    }
    
    private func GetText(_ key: String, _ alignment: Alignment, _ prefix: String? = nil, _ suffix: String? = nil) -> some View {
        return Text((prefix ?? "") + Localize.getString(key) + (suffix ?? ""))
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
        
enum TextType {
    case largeTitle
    case title
    case medium
    case body
    case settingsEntryTitle
}
