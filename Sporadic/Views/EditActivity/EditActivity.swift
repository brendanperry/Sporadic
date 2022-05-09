//
//  EditActivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI

struct EditActivity: View {
    @Environment(\.dismiss) var dismiss
    
    let textHelper = TextHelper()
    @ObservedObject var viewModel: EditActivityViewModel
    
    @Binding var isAdding: Bool
    
    init(activity: Activity, isAdding: Binding<Bool>) {
        viewModel = EditActivityViewModel(activity: activity, activityTemplateHelper: ActivityTemplateHelper(), notificationHelper: NotificationHelper(dataHelper: DataController.shared), dataHelper: DataController.shared)
        
        self._isAdding = isAdding
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        
                        viewModel.saveActivity()
                        isAdding = false
                        dismiss()
                    }) {
                        Image("CloseButton")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    .padding()
                    .buttonStyle(ButtonPressAnimationStyle())
                    
                    textHelper.GetTextByType(text: viewModel.activity.name ?? "Unkown" + " settings", isCentered: false, type: .title)
                        .padding(.leading)
                        .padding(.top, 100)
                    
                    textHelper.GetTextByType(text: "Edit your activity", isCentered: false, type: .body)
                        .padding([.leading, .bottom])
                    
                    textHelper.GetTextByType(text: "Toggle \(viewModel.activity.name ?? "Unkown")", isCentered: false, type: .settingsEntryTitle)
                        .padding([.leading, .top])
                    
                    Toggle("", isOn: $viewModel.isEnabled)
                        .labelsHidden()
                        .padding([.leading, .bottom])
                    
                    textHelper.GetTextByType(text: "Set the range for your challenge", isCentered: false, type: .settingsEntryTitle)
                        .padding()
                    
                    RangeSlider(lineHeight: 12,
                                lineWidth: UIScreen.main.bounds.width - 50,
                                lineCornerRadius: 10,
                                circleWidth: 30,
                                circleShadowRadius: 5,
                                roundToNearest: viewModel.activity.minRange,
                                minRange: viewModel.activity.minRange,
                                minValue: viewModel.activityTemplate.minValue,
                                maxValue: viewModel.activityTemplate.maxValue,
                                circleBorder: 4,
                                circleBorderColor: .white,
                                circleColor: .white,
                                lineColorInRange: Color("ActivityRangeColor"),
                                lineColorOutOfRange: Color("SliderBackground"),
                                leftValue: $viewModel.minValue,
                                rightValue: $viewModel.maxValue)
                        .frame(maxWidth: .infinity, maxHeight: 10, alignment: .center)
                    
                    textHelper.GetTextByType(text: "\(viewModel.minValue)\t\t-\t\t\(viewModel.maxValue)", isCentered: true, type: .title)
                    
                    textHelper.GetTextByType(text: "\(viewModel.activity.unit ?? "Unkown")", isCentered: true, type: .title)
                        .padding(.bottom)
                    
                    TotalMiles(viewModel: viewModel)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        
    }
    
    struct TotalMiles : View {
        let textHelper = TextHelper()
        let viewModel: EditActivityViewModel
        
        var body: some View {
            VStack {
                textHelper.GetTextByType(text: "You have \(viewModel.activity.name ?? "Unknown") a total of ", isCentered: false, type: .settingsEntryTitle)
                    .padding([.leading, .top])
                
                textHelper.GetTextByType(text: "\(viewModel.activity.total) \(viewModel.activity.unit ?? "Unknown")!", isCentered: false, type: .title, color: Color.green)
                    .padding([.leading])
            }
        }
    }
}
