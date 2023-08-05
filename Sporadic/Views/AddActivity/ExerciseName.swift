//
//  ExerciseName.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/8/23.
//

import SwiftUI

struct ExerciseName: View {
    let template: ActivityTemplate
    
    var body: some View {
        HStack {
            HStack {
                Image(template.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15, alignment: .center)
                    .padding([.vertical, .leading])
                
                Text(template.name)
                    .font(Font.custom("Lexend-SemiBold", size: 18, relativeTo: .title2))
                    .foregroundColor(Color("Gray400"))
                    .padding(.trailing)
            }
            .background(Color.white)
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            
            Spacer()
        }
    }
}
