//
//  GroupColor.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/26/22.
//

import SwiftUI

struct GroupColor: View {
    @Binding var selected: Int
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 4)
    
    var body: some View {
        VStack(alignment: .leading) {
            TextHelper.text(key: "Color", alignment: .leading, type: .h2)
            
            LazyVGrid(columns: items, spacing: 20) {
                ForEach(GroupBackgroundColor.allCases, id: \.self) { color in
                    Circle()
                        .foregroundColor(color.getColor())
                        .frame(width: color.rawValue == selected ? 40 : 50, height: color.rawValue == selected ? 40 : 50, alignment: .center)
                        .shadow(radius: color.rawValue == selected ? 3 : 0)
                        .animation(Animation.easeInOut, value: selected)
                        .onTapGesture {
                            withAnimation {
                                selected = color.rawValue
                            }
                        }
                }
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
