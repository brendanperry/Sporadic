//
//  ActivitySelector.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/10/22.
//

import SwiftUI

struct ActivitySelector: View {
    @Binding var selectedActivities: [Activity]
    @State var showEditMenu = false
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    let templates = ActivityTemplateHelper().getActivityTemplates()
    let afterAddAction: () -> Void
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                TextHelper.text(key: "AddANewActivity", alignment: .leading, type: .h1)
                    .padding(.top, 50)
                
                LazyVGrid(columns: items, spacing: 10) {
                    ForEach(templates.filter({ !selectedActivities.map({ $0.templateId }).contains($0.id) })) { template in
                        NavigationLink(destination: AddPage(activityList: $selectedActivities, template: template, afterAddAction: afterAddAction)) {
                            VStack {
                                Image(template.name + " Circle")
                                    .resizable()
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .padding(.top)
                                
                                TextHelper.text(key: template.name, alignment: .center, type: .activityTitle, color: .white)
                                    .padding(.top, 5)
                                    .padding(.bottom)
                            }
                            .padding(.vertical)
                            .background(
                                RoundedRectangle(cornerRadius: 15).foregroundColor(Color("Activity"))
                            )
                            .padding()
                        }
                        .buttonStyle(ButtonPressAnimationStyle())
                    }
                    
                    NavigationLink(destination: AddCustomActivityPage(activities: $selectedActivities)) {
                        Image("Add Activity Full")
                            .resizable()
                            .frame(width: 75, height: 75, alignment: .center)
                    }
                    .buttonStyle(ButtonPressAnimationStyle())
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(id: "BackButton", placement: .navigationBarLeading, showsByDefault: true) {
                BackButton()
            }
        }
    }
}
