//
//  CreateGroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import SwiftUI
import UIKit
import Combine

struct CreateGroupView: View {
    @ObservedObject var viewModel = CreateGroupViewModel()
    
    let reloadAction: (Bool) -> Void
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        TextHelper.text(key: "CreateGroup", alignment: .leading, type: .h1)
                            .padding(.horizontal)
                            .padding(.top, 50)
                        
                        GroupName(name: $viewModel.groupName)
                        
                        EmojiSelector(emoji: $viewModel.emoji)
                        
                        GroupColor(selected: $viewModel.color)
                        
                        DaysAndTime(days: $viewModel.days, time: $viewModel.time)
                        
                        SelectedActivityList(selectedActivities: $viewModel.activities, group: $viewModel.group, templates: viewModel.getTemplates())
                    }
                }
            }
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.groupName)
        .navigationBarItems(leading: BackButton(), trailing: CreateButton(viewModel: viewModel, reloadAction: reloadAction))
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .onAppear {
            UINavigationBar.appearance().barTintColor = UIColor(Color("Panel"))
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    struct CreateButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        let viewModel: CreateGroupViewModel
        let reloadAction: (Bool) -> Void
        
        var body: some View {
            Button(action: {
                Task {
                    let didFinishSuccessfully = await viewModel.createGroup()
                    
                    if didFinishSuccessfully {
                        reloadAction(false)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }, label: {
                Text(Localize.getString("CreateGroup"))
                    .font(.custom("Lexend-SemiBold", fixedSize: 10))
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color("Purple"))
                    .cornerRadius(12)
            })
            .buttonStyle(ButtonPressAnimationStyle())
        }
    }
    
    struct SelectedActivityList: View {
        @Binding var selectedActivities: [Activity]
        @Binding var group: UserGroup
        @State var showEditMenu = false
        var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
        let templates: [ActivityTemplate]
        
        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Activities", alignment: .leading, type: .h2)
                
                LazyVGrid(columns: items, spacing: 10) {
                    ForEach($selectedActivities) { activity in
                        NavigationLink(destination: EditActivity(activityList: $selectedActivities, activity: activity)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .top, endPoint: .bottom))
                                
                                VStack {
                                    if let _ = activity.wrappedValue.templateId {
                                        Image(activity.wrappedValue.name + " Circle")
                                            .resizable()
                                            .frame(width: 50, height: 50, alignment: .center)
                                    }
                                    else {
                                        Image("Custom Activity Icon")
                                            .resizable()
                                            .frame(width: 50, height: 50, alignment: .center)
                                    }
                                    
                                    TextHelper.text(key: activity.wrappedValue.name, alignment: .center, type: .activityTitle, color: .white)
                                        .padding(5)
                                    
                                    TextHelper.text(key: "\(activity.wrappedValue.minValue) - \(activity.wrappedValue.maxValue) \(activity.wrappedValue.unit.toAbbreviatedString())", alignment: .center, type: .body, color: Color("EditProfile"))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15).foregroundColor(Color("Activity"))
                                )
                                .padding(7)
                            }
                            .buttonStyle(ButtonPressAnimationStyle())
                        }
                        .buttonStyle(ButtonPressAnimationStyle())
                        .padding()
                    }
                    
                    NavigationLink(destination: ActivitySelector(selectedActivities: $selectedActivities)) {
                        Image("Add Activity Full")
                            .resizable()
                            .frame(width: 75, height: 75, alignment: .center)
                    }
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}
