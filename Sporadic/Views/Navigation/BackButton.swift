//
//  BackButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/10/22.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let showBackground: Bool
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(showBackground ? "BackButtonAutoTheme" : "BackButton")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundColor(showBackground ? Color("Panel") : .clear)
                        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                )
                
        })
        .hoverEffect()
        .buttonStyle(ButtonPressAnimationStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton(showBackground: true)
    }
}
