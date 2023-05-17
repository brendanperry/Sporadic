//
//  AddPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI
import CoreData
import CloudKit

struct AddCustomActivityPage: View {
    @StateObject var viewModel = AddActivityViewModel()
    @Binding var activities: [Activity]
    @State var showNetworkError = false
    @State var showNameError = false
    @Environment(\.dismiss) var dismiss
    
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .alert(isPresented: $showNetworkError) {
                    Alert(
                        title: Text(Localize.getString("NetworkError")),
                        message: Text(Localize.getString("CouldNotSaveActivity")),
                        dismissButton: .default(Text(Localize.getString("Okay"))))
                }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GlobalSettings.shared.controlSpacing) {
                    BackButton()
                        .padding(.top)
                    
                    TextHelper.text(key: "AddActivity", alignment: .leading, type: .h1)
                    
                    ActivityName(name: $viewModel.name)
                    
                    Units(selected: $viewModel.unit, viewModel: viewModel)
                    
                    RangeSelection(minValue: $viewModel.minValue, maxValue: $viewModel.maxValue, unit: viewModel.unit, viewModel: viewModel)
                        .alert(isPresented: $showNameError) {
                            Alert(
                                title: Text(Localize.getString("InvalidInput")),
                                message: Text(Localize.getString("ActivityNameError")),
                                dismissButton: .default(Text(Localize.getString("Okay"))))
                        }
                    
                    AddButton()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func AddButton() -> some View {
        Button(action: {
            if viewModel.name.count < 1 || viewModel.name.count > 18 {
                showNameError = true
            }
            else {
                activities.append(
                    Activity(
                        record: CKRecord(recordType: "Activity"),
                        maxValue: viewModel.maxValue,
                        minValue: viewModel.minValue,
                        name: viewModel.name,
                        templateId: -1,
                        unit: viewModel.unit,
                        isNew: true))
                
                dismiss()
            }
        }, label: {
            TextHelper.text(key: "AddToList", alignment: .center, type: .h5, color: .white)
                .padding()
                .frame(maxWidth: 150)
                .background(Color("BrandPurple"))
                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        })
        .buttonStyle(ButtonPressAnimationStyle())
    }
    
    struct Units: View {
        @Binding var selected: ActivityUnit
        let viewModel: AddActivityViewModel
        
        var body: some View {
            VStack {
                TextHelper.text(key: "SetRange", alignment: .leading, type: .h5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ActivityUnit.allCases, id: \.self) { unit in
                            TextHelper.text(key: unit.toString().capitalized(with: .current), alignment: .center, type: .h7, color: selected == unit ? .white : Color("Gray300"))
                                .padding()
                                .background(selected == unit ? Color("BrandPurple") : Color("Panel"))
                                .cornerRadius(16)
                                .onTapGesture {
                                    selected = unit
                                    viewModel.resetSlider(newUnit: unit)
                                }
                        }
                    }
                }
            }
        }
    }
    
    struct ActivityName: View {
        @Binding var name: String
        
        var body: some View {
            VStack {
                HStack {
                    TextHelper.text(key: "ActivityName", alignment: .leading, type: .h5)
                    
                    TextHelper.text(key: "MaxCharacters", alignment: .trailing, type: .h7)
                }
                
                TextField("", text: $name)
                    .padding(10)
                    .background(Color("Panel"))
                    .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .body))
                    .cornerRadius(10)
            }
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
                    leftCircleBorderColor: Color("Gradient1"),
                    rightCircleBorderColor: Color("Gradient2"),
                    leftCircleColor: .white,
                    rightCircleColor: .white,
                    lineColorInRange: AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing)),
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
