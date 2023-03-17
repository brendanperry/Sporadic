//
//  AddPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/8/22.
//

import SwiftUI
import CloudKit

struct AddPage: View {
    @Binding var activityList: [Activity]
    @State var minValue: Double
    @State var maxValue: Double
    
    let viewModel = AddActivityViewModel()
    let template: ActivityTemplate
    
    init(activityList: Binding<[Activity]>, template: ActivityTemplate) {
        self._activityList = activityList
        self.template = template
        
        self._minValue = State(initialValue: template.unit.defaultMin())
        self._maxValue = State(initialValue: template.unit.defaultMax())
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: GlobalSettings.shared.controlSpacing) {
                TextHelper.text(key: "Add exercise", alignment: .leading, type: .h1)
                    .padding(.top, 50)
                
                TextHelper.text(key: template.name, alignment: .leading, type: .h2)
                
                RangeSelection(minValue: $minValue, maxValue: $maxValue, unit: template.unit, viewModel: viewModel)
                
                AddButton(activityList: $activityList, minValue: minValue, maxValue: maxValue, template: template)
            }
            .padding(.horizontal)
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
        
        var body: some View {
            HStack {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    let newActivity = Activity(record: CKRecord(recordType: "Activity"), maxValue: maxValue, minValue: minValue, name: template.name, templateId: template.id, unit: template.unit)
                    newActivity.isNew = true
                    
                    DispatchQueue.main.async {
                        activityList.append(newActivity)
                    }
                    
                    dismiss()
                }) {
                    Text("Add to group")
                        .foregroundColor(.white)
                        .font(Font.custom("Lexend-SemiBold", size: 16, relativeTo: .title3))
                        .padding()
                        .background(Color("BrandPurple"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        .padding(.bottom)
                }
                .buttonStyle(ButtonPressAnimationStyle())
                .padding()
                
                Spacer()
            }
        }
    }
}
