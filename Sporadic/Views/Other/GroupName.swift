//
//  GroupName.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/26/22.
//

import SwiftUI


struct GroupName: View {
    @Binding var name: String
    @FocusState var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                TextHelper.text(key: "Name", alignment: .leading, type: .h4)
                
                TextHelper.text(key: "MaxCharacters", alignment: .trailing, type: .h7)
            }
            
            TextField("", text: $name.max(24))
                .padding(10)
                .background(Color("Panel"))
                .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .body))
                .cornerRadius(10)
                .focused($focused)
        }
        .onTapGesture {
            focused = true
        }
    }
}
