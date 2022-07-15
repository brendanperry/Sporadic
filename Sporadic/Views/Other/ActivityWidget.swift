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
    @Binding var isAdding: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 125, height: 125)
                .offset(x: 10, y: 10)
            
            VStack {
                Image(activity.name ?? "Unkown")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("ActivityBorderColor"))
            
                TextHelper.text(key: "", alignment: .center, type: .h2, prefix: activity.name)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 6)
                    .frame(width: 125, height: 125)
                    .foregroundColor(Color("ActivityBorderColor"))
            )
            .padding()
            .transition(.scale)
            
            Image("EditActivityDots")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .offset(x: 40, y: -40)
        }
        .padding()
        .onTapGesture {
            withAnimation {
                self.isEditing = true
            }
        }
        .fullScreenCover(isPresented: self.$isEditing) {
//            EditActivity(activity: self.activity)
        }
    }
}
