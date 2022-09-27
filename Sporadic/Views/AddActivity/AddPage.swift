//
//  AddPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI

struct AddPage: View {
    @Binding var activityList: [Activity]
    @State var minValue: Double
    @State var maxValue: Double
    
    let viewModel = AddActivityViewModel()
    let template: ActivityTemplate
    let afterAddAction: () -> Void
    
    init(activityList: Binding<[Activity]>, template: ActivityTemplate, afterAddAction: @escaping () -> Void) {
        self._activityList = activityList
        self.template = template
        
        self._minValue = State(initialValue: template.unit.defaultMin())
        self._maxValue = State(initialValue: template.unit.defaultMax())
        self.afterAddAction = afterAddAction
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                
                TextHelper.text(key: "AddActivity", alignment: .leading, type: .h1)
                    .padding(.top, 50)
                    .padding()
                
                TextHelper.text(key: template.name, alignment: .leading, type: .h2)
                    .padding([.horizontal, .top])
                
                TextHelper.text(key: "SetTheRangeForYourActivity", alignment: .leading, type: .h2)
                    .padding([.horizontal, .top])
                
                RangeSelection(selectedMin: $minValue, selectedMax: $maxValue, minValue: template.minValue, maxValue: template.maxValue, unit: template.unit, viewModel: viewModel)
                    .padding(.horizontal)
                
                AddButton(activityList: $activityList, minValue: minValue, maxValue: maxValue, template: template, afterAddAction: afterAddAction)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(id: "BackButton", placement: .navigationBarLeading, showsByDefault: true) {
                BackButton()
            }
        }
    }
    
    struct AddButton: View {
        @Environment(\.dismiss) var dismiss
        @Binding var activityList: [Activity]
        
        let minValue: Double
        let maxValue: Double
        let template: ActivityTemplate
        let afterAddAction: () -> Void
        
        var body: some View {
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                let newActivity = Activity(id: UUID(), isEnabled: true, maxValue: maxValue, minValue: minValue, name: template.name, templateId: template.id, unit: template.unit)
                
                activityList.append(newActivity)
                
                afterAddAction()
                
                dismiss()
            }) {
                TextHelper.text(key: "AddToList", alignment: .center, type: .h2, color: .white)
                    .padding()
                    .frame(width: 200)
                    .background(Color("Purple"))
                    .cornerRadius(16)
            }
            .buttonStyle(ButtonPressAnimationStyle())
            .padding()
        }
    }
    
    struct RangeSelection: View {
        @Binding var selectedMin: Double
        @Binding var selectedMax: Double
        let minValue: Double
        let maxValue: Double
        let unit: ActivityUnit
        let viewModel: AddActivityViewModel
        
        var body: some View {
            VStack {
                ZStack {
                    HStack {
                        HStack(alignment: .bottom, spacing: 1) {
                            Text("\(selectedMin, specifier: "%.2f")")
                                .font(Font.custom("Lexend-SemiBold", size: 17))
                            Text(unit.toAbbreviatedString())
                                .font(Font.custom("Lexend-SemiBold", size: 12.5))
                                .offset(y: -1)
                        }
                        .padding(.leading, 50)
                        
                        Spacer()

                        HStack(alignment: .bottom, spacing: 1) {
                            Text("\(selectedMax, specifier: "%.2f")")
                                .font(Font.custom("Lexend-SemiBold", size: 17))
                            Text(unit.toAbbreviatedString())
                                .font(Font.custom("Lexend-SemiBold", size: 12.5))
                                .offset(y: -1)
                        }
                        .padding(.trailing, 50)
                    }
                    
                    TextHelper.text(key: "-", alignment: .center, type: .h2)
                }
                
                RangeSlider(
                    lineHeight: 13,
                    lineWidth: UIScreen.main.bounds.width - 100,
                    lineCornerRadius: 16,
                    circleWidth: 35,
                    circleShadowRadius: 1,
                    minValue: minValue,
                    maxValue: maxValue,
                    circleBorder: 10,
                    leftCircleBorderColor: Color("RangeGradient1"),
                    rightCircleBorderColor: Color("Purple"),
                    leftCircleColor: .white,
                    rightCircleColor: .white,
                    lineColorInRange: AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [Color("RangeGradient1"), Color("Purple")]), startPoint: .leading, endPoint: .trailing)),
                    lineColorOutOfRange: Color("RangeUnselected"),
                    leftValue: $selectedMin,
                    rightValue: $selectedMax,
                    unitPublisher: viewModel.unitPublisher.eraseToAnyPublisher())
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(16)
        }
    }
}
