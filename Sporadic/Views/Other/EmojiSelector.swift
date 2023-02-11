//
//  EmojiSelector.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/26/22.
//

import SwiftUI

struct EmojiSelector: View {
    @Binding var emoji: String
    @FocusState var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            TextHelper.text(key: "Emoji", alignment: .leading, type: .h2)
            
            EmojiTextField(text: $emoji, focused: $focused)
                .font(.system(size: 100))
                .frame(width: 60, height: 60)
                .background(Color("Panel"))
                .cornerRadius(12)
                .focused($focused)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
