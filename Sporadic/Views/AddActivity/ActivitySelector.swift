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
    let templates = ActivityTemplateHelper.templates
    @Binding var shouldShow: Bool
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    CloseButton(shouldShow: $shouldShow)
                    
                    TextHelper.text(key: "AddANewActivity", alignment: .leading, type: .h1)
                        .padding(.top, 50)
                    
                    TextHelper.text(key: "Add new exercises to your group to be challenged with.", alignment: .leading, type: .body)
                    
                    ForEach(ActivityCategory.allCases) { category in
                        VStack {
                            TextHelper.text(key: category.rawValue, alignment: .leading, type: .h4)
                            
                            LazyVGrid(columns: items, spacing: 17) {
                                ForEach(templates.filter({ !selectedActivities.map({ $0.templateId }).contains($0.id) && $0.category == category })) { template in
                                    NavigationLink(destination: AddPage(activityList: $selectedActivities, template: template)) {
                                        VStack(alignment: .center) {
                                            Spacer()
                                            
                                            Image(template.name)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                                        .foregroundColor(template.color)
                                                )
                                            
                                            TextHelper.text(key: template.name, alignment: .center, type: .h3)
                                                .padding(.top, 5)
                                                .multilineTextAlignment(.center)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical)
                                        .background(
                                            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                                .foregroundColor(Color("Panel"))
                                                .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
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
                                Spacer()
                                
                                ZStack {
                                    Rectangle()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .foregroundColor(Color("CustomExercise"))
                                        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                                        .cornerRadius(10)

                                    Capsule(style: .continuous)
                                        .frame(width: 5, height: 25)
                                        .foregroundColor(Color("AddCrossUpCustom"))
                                    
                                    Capsule(style: .continuous)
                                        .rotation(.degrees(90))
                                        .frame(width: 5, height: 25)
                                        .foregroundColor(Color("AddCrossSideCustom"))
                                }
                                .padding([.horizontal, .top])
                                
                                Text("Add New")
                                    .font(Font.custom("Lexend-SemiBold", size: 19, relativeTo: .title2))
                                    .foregroundColor(Color("Gray300"))
                                    .padding(.top, 5)
                                    .padding(.bottom)
                                
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                    .foregroundColor(Color("Panel"))
                                    .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
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
                BackButton(showBackground: true)
            }
        }
    }
}
