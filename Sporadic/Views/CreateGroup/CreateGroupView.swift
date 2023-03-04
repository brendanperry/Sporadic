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
    @StateObject var viewModel = CreateGroupViewModel()
    @Binding var groups: [UserGroup]
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    TextHelper.text(key: "CreateGroup", alignment: .leading, type: .h1)
                        .padding(.horizontal)
                        .padding(.top, 50)
                    
                    GroupName(name: $viewModel.groupName)
                    
                    EmojiSelector(emoji: $viewModel.emoji)
                    
                    GroupColor(selected: $viewModel.color)
                    
                    StreakAndTime(isOwner: true, time: $viewModel.time)
                    
                    DaysForChallenges(availableDays: $viewModel.days, isOwner: true)
                    
                    SelectedActivityList(selectedActivities: $viewModel.activities, group: $viewModel.group, templates: viewModel.getTemplates())
                }
            }
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.groupName)
        .navigationBarItems(leading: BackButton(), trailing: CreateButton(groups: $groups, viewModel: viewModel))
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .toolbarBackground(viewModel.toolbarBackground, for: .navigationBar)
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    struct CreateButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @Binding var groups: [UserGroup]
        let viewModel: CreateGroupViewModel
        
        var body: some View {
            Button(action: {
                viewModel.createGroup { group in
                    if let group = group {
                        DispatchQueue.main.async {
                            groups.append(group)
                            groups.sort(by: { $0.name < $1.name })
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }, label: {
                Text(Localize.getString("Create"))
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
                    ForEach($selectedActivities, id: \.record.recordID) { activity in
                        NavigationLink(destination: EditActivity(activity: activity)) {
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
                    .padding(.top, selectedActivities.isEmpty ? 40 : 0)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}
