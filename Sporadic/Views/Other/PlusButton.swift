//
//  PlusButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/4/23.
//

import SwiftUI

struct PlusButton<Content: Shape>: View {
    let shape: Content
    let backgroundColor: Color
    let lockLightMode: Bool
    let shadow: Bool
    
    var body: some View {
        ZStack {
            shape
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(backgroundColor)
                .cornerRadius(10)

            Capsule(style: .continuous)
                .frame(width: 5, height: 25)
                .foregroundColor(lockLightMode ? Color("AddCrossUpLight") :Color("AddCrossUp"))
            
            Capsule(style: .continuous)
                .rotation(.degrees(90))
                .frame(width: 5, height: 25)
                .foregroundColor(lockLightMode ? Color("AddCrossSideLight") : Color("AddCrossSide"))
        }
        .shadow(color: Color("Shadow"), radius: shadow ? 16 : 0, x: 0, y: 4)
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton(shape: Circle(), backgroundColor: Color("Panel"), lockLightMode: false, shadow: true)
    }
}
