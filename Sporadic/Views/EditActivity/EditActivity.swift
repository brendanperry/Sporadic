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
//    @ObservedObject var viewModel: EditActivityViewModel
    
    @Binding var isAdding: Bool
    
    init(activity: Activity, isAdding: Binding<Bool>) {
//        viewModel = EditActivityViewModel(activity: activity, activityTemplateHelper: ActivityTemplateHelper(), notificationHelper: NotificationHelper(dataHelper: DataController.shared), dataHelper: DataController.shared)
        
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
                        
//                        viewModel.saveActivity()
                        isAdding = false
                        dismiss()
                    }) {
                        Image("CloseButton")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    .padding()
                    .buttonStyle(ButtonPressAnimationStyle())
                    
//                    textHelper.GetTextByType(key: viewModel.activity.name ?? "Unkown" + " settings", alignment: .leading, type: .title)
//                        .padding(.leading)
//                        .padding(.top, 100)
                    
                    textHelper.GetTextByType(key: "EditYourActivity", alignment: .leading, type: .body)
                        .padding([.leading, .bottom])
                    
//                    textHelper.GetTextByType(key: "Toggle", alignment: .leading, type: .settingsEntryTitle, suffix: " \(viewModel.activity.name ?? "Unkown")")
//                        .padding([.leading, .top])
                    
//                    Toggle("", isOn: $viewModel.isEnabled)
//                        .labelsHidden()
//                        .padding([.leading, .bottom])
                    
                    textHelper.GetTextByType(key: "SetTheRangeForYourActivity", alignment: .leading, type: .challengeAndSettings)
                        .padding()
                    
//                    RangeSlider(lineHeight: 12,
//                                lineWidth: UIScreen.main.bounds.width - 50,
//                                lineCornerRadius: 10,
//                                circleWidth: 30,
//                                circleShadowRadius: 5,
//                                roundToNearest: viewModel.activity.minRange,
//                                minRange: viewModel.activity.minRange,
//                                minValue: viewModel.activityTemplate.minValue,
//                                maxValue: viewModel.activityTemplate.maxValue,
//                                circleBorder: 4,
//                                circleBorderColor: .white,
//                                circleColor: .white,
//                                lineColorInRange: Color("ActivityRangeColor"),
//                                lineColorOutOfRange: Color("SliderBackground"),
//                                leftValue: $viewModel.minValue,
//                                rightValue: $viewModel.maxValue)
                        .frame(maxWidth: .infinity, maxHeight: 10, alignment: .center)
                    
//                    textHelper.GetTextByType(key: "", alignment: .center, type: .title, prefix: "\(viewModel.minValue)" + "\t\t-\t\t", suffix: "\(viewModel.maxValue)")
//                    
//                    textHelper.GetTextByType(key: "", alignment: .center, type: .title, suffix: "\(viewModel.activity.unit ?? "Unkown")")
//                        .padding(.bottom)
                    
//                    TotalMiles(viewModel: viewModel)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        
    }
    
    struct TotalMiles : View {
        let textHelper = TextHelper()
//        let viewModel: EditActivityViewModel
        
        var body: some View {
            VStack {
//                textHelper.GetTextByType(key: " \(viewModel.activity.name ?? "Unknown") ".lowercased(), alignment: .leading, type: .settingsEntryTitle, prefix: Localize.getString("YouHave"), suffix: Localize.getString("ATotalOf"))
//                    .padding([.leading, .top])
//                
//                textHelper.GetTextByType(key: "", alignment: .leading, type: .title, color: Color.green, prefix: "\(viewModel.activity.total) \(viewModel.activity.unit ?? "Unknown")!")
//                    .padding([.leading])
            }
        }
    }
}
