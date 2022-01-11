//
//  EditActivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI

struct EditActivity: View {
    @Binding var activity: Activity
    
    @EnvironmentObject var activityViewModel: ActivityViewModel
   
    let textHelper = TextHelper()
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack(alignment: .leading) {
                /*Button(action: {
                    self.isEditing = false
                }) {
                    Image(systemName: "arrow.backward")
                        .padding()
                }*/
                
                textHelper.GetTextByType(text: activity.name + " settings", isCentered: false, type: .title)
                    .padding(.leading)
                    .padding(.top, 100)
                
                textHelper.GetTextByType(text: "Edit your activity", isCentered: false, type: .body)
                    .padding([.leading, .bottom])
                
                textHelper.GetTextByType(text: "Toggle " + activity.name, isCentered: false, type: .settingsEntryTitle)
                    .padding([.leading, .top])
                
                Toggle("", isOn: self.$activity.isEnabled)
                    .labelsHidden()
                    .padding([.leading, .bottom])
                    .onChange(of: self.activity.isEnabled, perform: { _ in
                        self.activityViewModel.saveActivity(activity: self.activity)
                    })
                
                textHelper.GetTextByType(text: "Set the range for your challenge", isCentered: false, type: .settingsEntryTitle)
                    .padding()
                
                RangeSlider(lineHeight: 12, lineWidth: geometryReader.size.width - 50, lineCornerRadius: 10, circleWidth: 30, circleShadowRadius: 5, roundToNearest: 0.25, minRange: 0.25, minValue: 0, maxValue: 10, circleBorder: 4, circleBorderColor: .blue, circleColor: .white, lineColorInRange: .blue, lineColorOutOfRange: Color(UIColor.lightGray), leftValue: self.$activity.minValue, rightValue: self.$activity.maxValue)
                    .frame(maxWidth: .infinity, maxHeight: 10, alignment: .center)
                    .onChange(of: self.activity.minValue, perform: { _ in
                        self.activityViewModel.saveActivity(activity: self.activity)
                    })
                    .onChange(of: self.activity.maxValue, perform: { _ in
                        self.activityViewModel.saveActivity(activity: self.activity)
                    })
                
                textHelper.GetTextByType(text: "You have walked a total of ", isCentered: false, type: .settingsEntryTitle)
                    .padding([.leading, .top])
                
                textHelper.GetTextByType(text: "\(self.activity.total) miles!", isCentered: false, type: .title, color: Color.green)
                    .padding([.leading])
            }
        }
    }
}
