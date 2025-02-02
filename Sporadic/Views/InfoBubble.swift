//
//  InfoBubble.swift
//  Sporadic
//
//  Created by Brendan Perry on 2/1/25.
//

import SwiftUI

struct InfoBubble: View {
    let text: String
    let hide: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundStyle(Color("BrandBlue"))
                .padding(.bottom, 5)
            
            TextHelper.text(key: text, alignment: .leading, type: .body)
            
            HStack {
                Spacer()
                
                Button(action: {
                    hide()
                }, label: {
                    TextHelper.text(key: "Dismiss", alignment: .center, type: .h5, color: Color("CancelText"))
                        .padding()
                        .background(Color("Cancel"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .frame(width: 150)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                .foregroundStyle(Color("Panel"))
                .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
        )
        .padding(.horizontal)
        .transition(.opacity)
    }
}

#Preview {
    InfoBubble(text: "We've set up a group for you to get started. Groups consist of exercises and friends that you invite. You can edit your group by tapping on it or create a new one by hitting the plus button.") { }
}
