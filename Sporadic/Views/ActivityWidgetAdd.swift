
//
//  ActivityWidgetAdd.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/28/21.
//

import SwiftUI

struct ActivityWidgetAdd: View {
    var activity: Activity

    @Binding var activityToEdit: Activity
    @Binding var isEditing: Bool
    
    let textHelper = TextHelper()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 125, height: 125)
                .offset(x: 10, y: 10)
            
            VStack {
                Image(activity.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("ActivityBorderColor"))
            
                textHelper.GetTextByType(text: activity.name, isCentered: true, type: .title)
                    .font(Font.custom("Gilroy", size: 30, relativeTo: .title))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 6)
                    .frame(width: 125, height: 125)
                    .foregroundColor(Color("ActivityBorderColor"))
            )
            .padding()
            .transition(.scale)
        }
        .onTapGesture {
            self.activityToEdit = self.activity
            self.isEditing = true
        }
        .padding()
    }
}
