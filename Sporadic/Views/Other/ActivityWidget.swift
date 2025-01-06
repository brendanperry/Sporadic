//
//  ActivityWidget.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/16/24.
//
import SwiftUI

struct ActivityWidget: View {
    let template: ActivityTemplate
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image(template.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundColor(template.color)
                )
            
            TextHelper.text(key: template.name, alignment: .center, type: .h3)
                .padding(.top, 5)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                .foregroundColor(Color("Panel"))
                .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
        )
    }
}
