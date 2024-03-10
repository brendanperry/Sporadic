//
//  GroupIcon.swift
//  Sporadic
//
//  Created by brendan on 12/18/23.
//

import Foundation
import SwiftUI

struct GroupIcon: View {
    let emoji: String
    let backgroundColor: Int
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .foregroundColor(GroupBackgroundColor.init(rawValue: backgroundColor)?.getColor())
            
            Text(emoji)
                .font(.system(size: 25))
        }
    }
}
