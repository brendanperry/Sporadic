//
//  PlusButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/4/23.
//

import SwiftUI

struct PlusButton: View {
    let backgroundColor: Color? = nil
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(backgroundColor != nil ? backgroundColor : Color("Panel"))
                .shadow(radius: 3)
                .cornerRadius(10)
            
            Capsule(style: .continuous)
                .rotation(.degrees(90))
                .frame(width: 5, height: 25)
                .foregroundColor(Color("Gray300"))

            Capsule(style: .continuous)
                .frame(width: 5, height: 25)
                .foregroundColor(Color("Gray300"))
        }
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
    }
}