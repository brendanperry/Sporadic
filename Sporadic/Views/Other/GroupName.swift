//
//  GroupName.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/26/22.
//

import SwiftUI


struct GroupName: View {
    @Binding var name: String
    
    var body: some View {
        VStack {
            TextHelper.text(key: "GroupName", alignment: .leading, type: .h2)
            
            TextField("", text: $name)
                .padding(10)
                .background(Color("Panel"))
                .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .body))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
