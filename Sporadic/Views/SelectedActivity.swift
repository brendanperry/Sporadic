//
//  SelectedActivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/16/23.
//

import SwiftUI

struct SelectedActivity: View {
    @Binding var activity: Activity
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.white)
                
                Image(activity.templateId == -1 ? "Custom Activity Icon" : activity.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                            .foregroundColor(activity.template?.color ?? Color("CustomExercise"))
                    )
            }
            
            TextHelper.text(key: activity.name, alignment: .center, type: .h3)
                .padding(.top)
            
            TextHelper.text(key: "\(activity.minValue) - \(activity.maxValue)", alignment: .center, type: .h7)
                .opacity(0.75)
            
            TextHelper.text(key: "\(activity.unit.toString())", alignment: .center, type: .h7)
                .opacity(0.75)
        }
        .padding()
        .background(Color("Panel"))
        .cornerRadius(10)
        .shadow(radius: GlobalSettings.shared.shadowRadius)
    }
}
