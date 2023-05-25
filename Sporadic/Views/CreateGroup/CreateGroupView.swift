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
                VStack(spacing: GlobalSettings.shared.controlSpacing) {
                    BackButton()
                        .padding(.top)
                    
                    TextHelper.text(key: "CreateGroup", alignment: .leading, type: .h1)
                    
                    GroupName(name: $viewModel.groupName)
                    
                    EmojiSelector(emoji: $viewModel.emoji)
                    
                    GroupColor(selected: $viewModel.color)
                    
                    DeliveryTime(isOwner: true, time: $viewModel.time)
                    
                    DaysForChallenges(availableDays: $viewModel.days, isOwner: true)
                    
                    SelectedActivityList(selectedActivities: $viewModel.activities, group: $viewModel.group, templates: viewModel.getTemplates())
                    
                    CreateButton(groups: $groups, viewModel: viewModel)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            
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
                TextHelper.text(key: "Create Group", alignment: .center, type: .h5, color: .white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color("BrandPurple"))
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            })
            .buttonStyle(ButtonPressAnimationStyle())
            .padding()
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
                TextHelper.text(key: "Activities", alignment: .leading, type: .h2)
                
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
                        PlusButton(backgroundColor: Color("Panel"))
                    })
                    .buttonStyle(ButtonPressAnimationStyle())
                    .padding(.top, selectedActivities.isEmpty ? 40 : 0)
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
