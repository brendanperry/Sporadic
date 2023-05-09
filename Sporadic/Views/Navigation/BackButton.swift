//
//  BackButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/10/22.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image("BackButton")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundColor(Color("Panel"))
                )
                
        })
        .buttonStyle(ButtonPressAnimationStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton()
    }
}
