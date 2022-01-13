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
    
    let topSafeArea: Double
    
    let textHelper = TextHelper()
    
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack {
            GeometryReader { geometryReader in
                VStack(alignment: .leading) {
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
                        .onChange(of: self.activity.isEnabled, perform: { _ in
                            self.activityViewModel.saveActivity(activity: self.activity)
                        })
                    
                    textHelper.GetTextByType(text: "Set the range for your challenge", isCentered: false, type: .settingsEntryTitle)
                        .padding()
                    
                    RangeSlider(lineHeight: 12,
                                lineWidth: geometryReader.size.width - 50,
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
                        .onChange(of: self.activity.selectedMax, perform: { _ in
                            self.activityViewModel.saveActivity(activity: self.activity)
                        })
                        .onChange(of: self.activity.selectedMin, perform: { _ in
                            self.activityViewModel.saveActivity(activity: self.activity)
                        })
                    
                    textHelper.GetTextByType(text: "\(self.activity.selectedMin)\(self.activity.unitAbbreviation)\t\t-\t\t\(self.activity.selectedMax)\(self.activity.unitAbbreviation)", isCentered: true, type: .title, color: Color.black)
                        .padding(.bottom)
                    
                    textHelper.GetTextByType(text: "You have \(self.activity.pastTense) a total of ", isCentered: false, type: .settingsEntryTitle)
                        .padding([.leading, .top])
                    
                    textHelper.GetTextByType(text: "\(self.activity.total) \(self.activity.unit)!", isCentered: false, type: .title, color: Color.green)
                        .padding([.leading])
                    
                    Text("\(activityViewModel.dummy)")
                }
            }
            .background(.white)
            .frame(width: UIScreen.main.bounds.width, height: self.isEditing ? UIScreen.main.bounds.height - self.topSafeArea : 0, alignment: .bottom)
            .clipped()
            .animation(Animation.easeInOut(duration: 0.25), value: self.isEditing)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
