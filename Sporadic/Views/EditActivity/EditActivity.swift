//
//  EditActivity.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI

struct EditActivity: View {
    @Binding var activityList: [Activity]
    @Binding var activity: Activity
    
    let viewModel = AddActivityViewModel()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                TextHelper.text(key: "EditYourActivity", alignment: .leading, type: .h1)
                    .padding(.horizontal)
                    .padding(.top, 50)
                
                TextHelper.text(key: "AddToGroup", alignment: .leading, type: .h2)
                    .padding([.leading, .top])
                
                TextHelper.text(key: "SetTheRangeForYourActivity", alignment: .leading, type: .h2)
                    .padding(.horizontal)
                
                RangeSelection(minValue: $activity.minValue, maxValue: $activity.maxValue, unit: activity.unit, viewModel: viewModel)
                    .padding([.horizontal, .bottom])
                
                DeleteButton(activityList: $activityList, activity: $activity)
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
    
    struct DeleteButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @State var showDeleteConfirmation = false
        @Binding var activityList: [Activity]
        @Binding var activity: Activity
        
        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "RemovingActivities", alignment: .leading, type: .h2)
                
                Button(action: {
                    showDeleteConfirmation = true
                }, label: {
                    TextHelper.text(key: "RemoveActivity", alignment: .center, type: .h2)
                        .padding()
                        .frame(width: 150, height: 40, alignment: .leading)
                        .background(Color("Delete"))
                        .cornerRadius(16)
                        .padding(.bottom)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(title: Text("Remove \(activity.name)?"), message: Text("Add back an activity with the same name later to pick up where you left off."),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Remove")) {
                        activity.isEnabled = false
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    struct RangeSelection: View {
        @Binding var minValue: Double
        @Binding var maxValue: Double
        let unit: ActivityUnit
        let viewModel: AddActivityViewModel
        
        var body: some View {
            VStack {
                ZStack {
                    HStack {
                        HStack(alignment: .bottom, spacing: 1) {
                            Text("\(minValue, specifier: "%.2f")")
                                .font(Font.custom("Lexend-SemiBold", size: 17))
                            Text(unit.toAbbreviatedString())
                                .font(Font.custom("Lexend-SemiBold", size: 12.5))
                                .offset(y: -1)
                        }
                        .padding(.leading, 50)
                        
                        Spacer()

                        HStack(alignment: .bottom, spacing: 1) {
                            Text("\(maxValue, specifier: "%.2f")")
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
                    minValue: unit.minValue(),
                    maxValue: unit.maxValue(),
                    circleBorder: 10,
                    leftCircleBorderColor: Color("RangeGradient1"),
                    rightCircleBorderColor: Color("Purple"),
                    leftCircleColor: .white,
                    rightCircleColor: .white,
                    lineColorInRange: AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [Color("RangeGradient1"), Color("Purple")]), startPoint: .leading, endPoint: .trailing)),
                    lineColorOutOfRange: Color("RangeUnselected"),
                    leftValue: $minValue,
                    rightValue: $maxValue,
                    unitPublisher: viewModel.unitPublisher.eraseToAnyPublisher())
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(16)
        }
    }
}
