//
//  EditIcon.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/16/23.
//

import SwiftUI

struct EditIcon: View {
    var body: some View {
        Image("Edit Group Icon")
            .resizable()
            .frame(width: 15, height: 15, alignment: .center)
            .background(
                Circle()
                    .foregroundColor(.white)
                    .opacity(0.75)
                    .frame(width: 25, height: 25, alignment: .center)
                    .offset(x: -1, y: -1)
            )
    }
}

struct EditIcon_Previews: PreviewProvider {
    static var previews: some View {
        EditIcon()
    }
}
