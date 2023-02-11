//
//  StreakAndTime.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/10/22.
//

import SwiftUI

struct StreakAndTime: View {
    let dateHelper = DateHelper()
    let isOwner: Bool
    
    @Binding var time: Date
    @State var isPresented = false
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Challenges", alignment: .leading, type: .h2)
            
            HStack(spacing: 25) {
                Group {
                    VStack {
                        Text("Streak")
                            .font(Font.custom("Lexend-Regular", size: 16, relativeTo: .title2))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("Body"))
                        
                        Text("0")
                            .font(Font.custom("Lexend-SemiBold", size: 30, relativeTo: .title2))
                            .frame(width: 200, height: 50, alignment: .center)
                            .background(Color("Panel"))
                            .userInteractionDisabled()
                    }
                    VStack {
                        Text(Localize.getString("DeliveryTime"))
                            .font(Font.custom("Lexend-Regular", size: 16, relativeTo: .title2))
                            .foregroundColor(Color("Body"))
                            .zIndex(1.0)
                        
                        ZStack {
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 125)
                                .scaleEffect(1.6)
                                .disabled(!isOwner)
                                .onAppear {
                                    UIDatePicker.appearance().minuteInterval = 15
                                }
                            
                            Group {
                                Text(dateHelper.getHoursAndMinutes(date: time))
                                    .font(Font.custom("Lexend-SemiBold", size: 30, relativeTo: .title2)) +
                                Text(" ") +
                                Text(dateHelper.getAmPm(date: time))
                                    .font(Font.custom("Lexend-SemiBold", size: 20, relativeTo: .title2))
                            }
                            .frame(width: 200, height: 200, alignment: .center)
                            .background(Color("Panel"))
                            .userInteractionDisabled()
                        }
                        .background(Color("Panel"))
                    }
                }
                .frame(height: 75, alignment: .center)
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color("Panel"))
                .cornerRadius(15)
            }
        }
        .padding(.horizontal)
    }
}
