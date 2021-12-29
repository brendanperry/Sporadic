//
//  TextHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/12/21.
//

import SwiftUI
import Foundation

class TextHelper {
    func GetTextByType(text: String, isCentered: Bool, type: TextType) -> some View {
        switch(type) {
        case TextType.largeTitle:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
                .foregroundColor(Color("LooksLikeBlack")))
        case TextType.title:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy", size: 32, relativeTo: .title)))
        case TextType.medium:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .subheadline))
                .foregroundColor(Color("SubHeadingColor")))
        case .body:
            return AnyView(GetText(text, isCentered)
                .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                .foregroundColor(Color("LooksLikeBlack")))
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
