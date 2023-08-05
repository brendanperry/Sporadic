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
    
    let updateNextChallengeText: () -> Void
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: GlobalSettings.shared.controlSpacing) {
                        TextHelper.text(key: "CreateGroup", alignment: .leading, type: .h1)
                            .padding(.top, 100)
                        
                        GroupName(name: $viewModel.groupName)
                        
                        EmojiSelector(emoji: $viewModel.emoji)
                        
                        GroupColor(selected: $viewModel.color)
                        
                        DeliveryTime(isOwner: true, time: $viewModel.time)
                        
                        DaysForChallenges(availableDays: $viewModel.days, isOwner: true)
                        
                        SelectedActivityList(selectedActivities: $viewModel.activities, group: $viewModel.group, templates: viewModel.getTemplates())
                        
                        CreateButton(groups: $groups, viewModel: viewModel, updateNextChallengeText: updateNextChallengeText)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 1)
                
                VStack {
                    BackButton(showBackground: true)
                    
                    Spacer()
                }
                .padding()
            }
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    struct CreateButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @Binding var groups: [UserGroup]
        let viewModel: CreateGroupViewModel
        
        let updateNextChallengeText: () -> Void
        
        var body: some View {
            Button(action: {
                viewModel.createGroup { group in
                    if let group = group {
                        DispatchQueue.main.async {
                            groups.append(group)
                            groups.sort(by: { $0.name < $1.name })
                            
                            updateNextChallengeText()
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }, label: {
                Text("Create Group")
                    .font(.custom("Lexend-Regular", size: 15))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .padding(.horizontal)
                    .background(Color("BrandPurple"))
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            })
            .buttonStyle(ButtonPressAnimationStyle())
            .padding()
            .padding(.bottom, 50)
        }
    }
    
    struct SelectedActivityList: View {
        @Binding var selectedActivities: [Activity]
        @Binding var group: UserGroup
        @State var showAddView = false
        var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 3)
        let templates: [ActivityTemplate]
        
        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Exercises", alignment: .leading, type: .h4)
                
                LazyVGrid(columns: items, spacing: 17) {
                    ForEach($selectedActivities, id: \.record.recordID) { activity in
                        NavigationLink(destination: EditActivity(activity: activity, activities: $selectedActivities)) {
                            SelectedActivity(activity: activity)
                        }
                        .buttonStyle(ButtonPressAnimationStyle())
                    }
                    
                    Button(action: {
                        showAddView = true
                    }, label: {
                        if selectedActivities.isEmpty {
                            VStack(alignment: .center) {
                                Spacer()
                                
                                PlusButton(backgroundColor: .clear, lockLightMode: true)
                                    .frame(width: 25)
                                    .padding(10)
                                    .background(Circle().foregroundColor(Color("BrandPurple")))
                                
                                Spacer()
                                
                                TextHelper.text(key: "Add an exercise!", alignment: .center, type: .h3)
                                    .padding()
                                
                                Spacer()
                            }
                            .background(Color("Panel"))
                            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                        }
                        else {
                            PlusButton(backgroundColor: Color("Panel"), lockLightMode: false)
                        }
                    })
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
            .popover(isPresented: $showAddView) {
                NavigationStack {
                    ActivitySelector(selectedActivities: $selectedActivities, shouldShow: $showAddView)
                }
            }
        }
    }
}
