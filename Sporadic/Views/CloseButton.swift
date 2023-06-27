//
//  CloseButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/26/23.
//

import SwiftUI

struct CloseButton: View {
    @Binding var shouldShow: Bool
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            shouldShow = false
        }) {
            Image("CloseButton")
                .resizable()
                .frame(width: 15, height: 15, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundColor(Color("Panel"))
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .buttonStyle(ButtonPressAnimationStyle())
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton(shouldShow: .constant(true))
    }
}
