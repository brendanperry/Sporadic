//
//  ActivitySelector.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/10/22.
//

import SwiftUI

struct ActivitySelector: View {
    @Binding var selectedActivities: [Activity]
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 3)
    let templates = ActivityTemplateHelper().getActivityTemplates()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    TextHelper.text(key: "AddANewActivity", alignment: .leading, type: .h1)
                        .padding(.top, 50)
                    
                    TextHelper.text(key: "Add new exercises to your group to be challenged with.", alignment: .leading, type: .body)
                    
                    ForEach(ActivityCategory.allCases) { category in
                        VStack {
                            TextHelper.text(key: category.rawValue, alignment: .leading, type: .h4)
                            
                            LazyVGrid(columns: items, spacing: 17) {
                                ForEach(templates.filter({ !selectedActivities.map({ $0.templateId }).contains($0.id) && $0.category == category })) { template in
                                    NavigationLink(destination: AddPage(activityList: $selectedActivities, template: template)) {
                                        VStack {
                                            Image(template.name + " Circle")
                                                .resizable()
                                                .frame(width: 50, height: 50, alignment: .center)
                                                .padding(.top)
                                            
                                            TextHelper.text(key: template.name, alignment: .center, type: .h2)
                                                .padding(.top, 5)
                                                .padding(.bottom)
                                        }
                                        .padding(.vertical)
                                        .background(
                                            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                                .foregroundColor(Color("Panel"))
                                                .shadow(radius: GlobalSettings.shared.shadowRadius)
                                        )
                                    }
                                    .buttonStyle(ButtonPressAnimationStyle())
                                }
                            }
                        }
                    }
                    .padding(.top)
                    
                    HStack {
                        NavigationLink(destination: AddCustomActivityPage(activities: $selectedActivities)) {
                            VStack {
//                                PlusButton(backgroundColor: )
                                
                                Text("Add New")
                                    .font(Font.custom("Lexend-SemiBold", size: 14, relativeTo: .title))
                                    .foregroundColor(Color("Gray300"))
                                    .padding(.top, 5)
                                    .padding(.bottom)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                    .foregroundColor(Color("Panel"))
                                    .shadow(radius: GlobalSettings.shared.shadowRadius)
                            )
                        }
                        .buttonStyle(ButtonPressAnimationStyle())
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // this is used as a swift ui bug where the keyboard space is eaten up despite it being
            // dropped after navigating away
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
        }
        .toolbar {
            ToolbarItem(id: "BackButton", placement: .navigationBarLeading, showsByDefault: true) {
                BackButton()
            }
        }
    }
}
