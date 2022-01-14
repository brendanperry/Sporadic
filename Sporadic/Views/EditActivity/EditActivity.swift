//
//  Editactivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI

struct EditActivity: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @State var activity: Activity
    @Binding var isEditing: Bool
    
    let textHelper = TextHelper()
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Button("Close") {
                    self.activityViewModel.saveActivity(activity: self.activity)
                    self.isEditing = false
                }
                textHelper.GetTextByType(text: activity.name + " settings", isCentered: false, type: .title)
                    .padding(.leading)
                    .padding(.top, 100)
                
                textHelper.GetTextByType(text: "Edit your activity", isCentered: false, type: .body)
                    .padding([.leading, .bottom])
                
                textHelper.GetTextByType(text: "Toggle \(activity.presentTense)", isCentered: false, type: .settingsEntryTitle)
                    .padding([.leading, .top])
                
                Toggle("", isOn: self.$activity.isEnabled)
                    .labelsHidden()
                    .padding([.leading, .bottom])
                
                textHelper.GetTextByType(text: "Set the range for your challenge", isCentered: false, type: .settingsEntryTitle)
                    .padding()
                
                RangeSlider(lineHeight: 12,
                            lineWidth: UIScreen.main.bounds.width - 50,
                            lineCornerRadius: 10,
                            circleWidth: 30,
                            circleShadowRadius: 5,
                            roundToNearest: activity.minRange,
                            minRange: activity.minRange,
                            minValue: activity.minValue,
                            maxValue: activity.maxValue,
                            circleBorder: 4,
                            circleBorderColor: .blue,
                            circleColor: .white,
                            lineColorInRange: .blue,
                            lineColorOutOfRange: .gray,
                            leftValue: $activity.selectedMin,
                            rightValue: $activity.selectedMax)
                    .frame(maxWidth: .infinity, maxHeight: 10, alignment: .center)
                
                textHelper.GetTextByType(text: "\(self.activity.selectedMin)\(self.activity.unitAbbreviation)\t\t-\t\t\(self.activity.selectedMax)\(self.activity.unitAbbreviation)", isCentered: true, type: .title, color: Color.black)
                    .padding(.bottom)
                
                textHelper.GetTextByType(text: "You have \(self.activity.pastTense) a total of ", isCentered: false, type: .settingsEntryTitle)
                    .padding([.leading, .top])
                
                textHelper.GetTextByType(text: "\(self.activity.total) \(self.activity.unit)!", isCentered: false, type: .title, color: Color.green)
                    .padding([.leading])
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
