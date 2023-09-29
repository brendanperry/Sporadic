//
//  DeliveryTime.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/10/22.
//

import SwiftUI

struct DeliveryTime: View {
    let dateHelper = DateHelper()
    let isOwner: Bool
    
    @Binding var time: Date
    @State var isPresented = false
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Notification delivery", alignment: .leading, type: .h4)
            
            HStack(spacing: 25) {
                ZStack {
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(width: 300)
                        .scaleEffect(1.6)
                        .disabled(!isOwner)
                        .onAppear {
                            UIDatePicker.appearance().minuteInterval = 30
                        }
                    
                    VStack {
                        Group {
                            Text(dateHelper.getHoursAndMinutes(date: time))
                                .font(Font.custom("Lexend-SemiBold", size: 30, relativeTo: .title2))
                                .foregroundColor(Color("Gray300")) +
                            Text(" ") +
                            Text(dateHelper.getAmPm(date: time))
                                .font(Font.custom("Lexend-SemiBold", size: 20, relativeTo: .title2))
                                .foregroundColor(Color("Gray300"))
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color("Panel"))
                    .userInteractionDisabled()
                }
                .padding(.vertical)
                .background(Color("Panel"))
                .frame(maxWidth: .infinity)
                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            }
        }
    }
}
