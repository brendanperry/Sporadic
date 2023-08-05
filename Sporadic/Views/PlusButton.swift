//
//  PlusButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/4/23.
//

import SwiftUI

struct PlusButton: View {
    let backgroundColor: Color
    let lockLightMode: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(backgroundColor)
                .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                .cornerRadius(10)

            Capsule(style: .continuous)
                .frame(width: 5, height: 25)
                .foregroundColor(lockLightMode ? Color("AddCrossUpLight") :Color("AddCrossUp"))
            
            Capsule(style: .continuous)
                .rotation(.degrees(90))
                .frame(width: 5, height: 25)
                .foregroundColor(lockLightMode ? Color("AddCrossSideLight") :Color("AddCrossSide"))
        }
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton(backgroundColor: Color("Panel"), lockLightMode: false)
    }
}
