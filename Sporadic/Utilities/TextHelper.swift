//
//  TextHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/12/21.
//

import SwiftUI
import Foundation

class TextHelper {
    func GetTextByType(text: String, isCentered: Bool, type: TextType, color: Color? = nil) -> some View {
        switch(type) {
        case TextType.largeTitle:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
                .foregroundColor(color == nil ? Color("LooksLikeBlack") : color))
        case TextType.title:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy", size: 32, relativeTo: .title))
                .foregroundColor(color == nil ? Color.black : color))
        case TextType.medium:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .subheadline))
                .foregroundColor(color == nil ? Color("SubHeadingColor") : color))
        case .body:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy-Medium", size: 16, relativeTo: .body))
                .foregroundColor(color == nil ? Color(UIColor.lightGray) : color))
        case .settingsEntryTitle:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy", size: 18, relativeTo: .title3)))
        }
    }
    
    private func GetText(_ text: String, _ isCentered: Bool) -> some View {
        return Text(text)
            .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
    }
}
        
enum TextType {
    case largeTitle
    case title
    case medium
    case body
    case settingsEntryTitle
}
