//
//  ActivityWidget.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/15/21.
//

import SwiftUI

struct ActivityWidget: View {
    @State var activity: Activity
    @State var isEditing = false
    let textHelper = TextHelper()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 125, height: 125)
                .offset(x: 10, y: 10)
            
            Button(action: {
                withAnimation {
                    self.isEditing = true
                }
            }, label: {
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color("ActivityBorderColor"))
            })
            .offset(x: 45, y: -45)
            
            VStack {
                Image(activity.name ?? "Unkown")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("ActivityBorderColor"))
            
                textHelper.GetTextByType(text: activity.name ?? "Unkown", isCentered: true, type: .title)
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
        .padding()
        .fullScreenCover(isPresented: self.$isEditing) {
            EditActivity(activity: self.activity)
        }
    }
}
