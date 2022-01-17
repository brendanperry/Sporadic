//
//  Editactivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI

struct EditActivity: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var activity: Activity
    @State var isEnabled: Bool
    let textHelper = TextHelper()
    
    init(activity: Activity) {
        self._activity = State.init(initialValue: activity)
        self._isEnabled = State.init(initialValue: activity.isEnabled)
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Button("Close") {
                        activity.isEnabled = isEnabled
                        try? managedObjectContext.save()
                        
                        let notificationHelper = NotificationHelper(context: managedObjectContext)
                        
                        notificationHelper.scheduleAllNotifications()
                        
                        dismiss()
                    }
                    .padding()
                    
                    textHelper.GetTextByType(text: activity.name ?? "Unkown" + " settings", isCentered: false, type: .title)
                        .padding(.leading)
                        .padding(.top, 100)
                    
                    textHelper.GetTextByType(text: "Edit your activity", isCentered: false, type: .body)
                        .padding([.leading, .bottom])
                    
                    textHelper.GetTextByType(text: "Toggle \(activity.name ?? "Unkown")", isCentered: false, type: .settingsEntryTitle)
                        .padding([.leading, .top])
                    
                    Toggle("", isOn: self.$isEnabled)
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
                    
                    textHelper.GetTextByType(text: "\(self.activity.selectedMin)\(self.activity.unit ?? "Unknown")\t\t-\t\t\(self.activity.selectedMax)\(self.activity.unit ?? "Unkown")", isCentered: true, type: .title)
                        .padding(.bottom)
                    
                    textHelper.GetTextByType(text: "You have \(self.activity.name ?? "Unknown") a total of ", isCentered: false, type: .settingsEntryTitle)
                        .padding([.leading, .top])
                    
                    textHelper.GetTextByType(text: "\(self.activity.total) \(self.activity.unit ?? "Unknown")!", isCentered: false, type: .title, color: Color.green)
                        .padding([.leading])
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
    }
}
