//
//  Activities.swift
//  Sporadic
//
//  Created by Brendan Perry on 10/19/21.
//

import SwiftUI
import Introspect

struct Activities: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel

    
    var body: some View {
        VStack {
            Text(Localize.getString("Activities"))
                .foregroundColor(Color("SubHeadingColor"))
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top)
            HStack {
                VStack {
                    ForEach(Array(activityViewModel.activities.enumerated()), id: \.offset) { index, activity in
                        if (index % 2 == 0) {
                            ActivityWidget(activity: activity)
                        }
                    }
                }
                VStack {
                    ForEach(Array(activityViewModel.activities.enumerated()), id: \.offset) { index, activity in
                        if (index % 2 != 0) {
                            ActivityWidget(activity: activity)
                        }
                    }
                }
            }
        }
    }
}

struct ActivityWidget: View {
    var activity: Activity

    @EnvironmentObject var activityViewModel: ActivityViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 125, height: 125)
                .offset(x: 15, y: 15)
            
            Button(action: {

            }, label: {
                Image(systemName: "pencil.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(Color("ActivityBorderColor"))
            })
            .offset(x: 45, y: -45)
            
            VStack {
                Image(activity.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("ActivityBorderColor"))
            
                Text(activity.name)
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
        .padding()
    }
}
