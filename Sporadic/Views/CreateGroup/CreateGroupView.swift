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
                        
                        GroupColor(color: $viewModel.color)
                        
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
        .navigationBarItems(leading: BackButton(), trailing: CreateButton(viewModel: viewModel))
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .onAppear {
            UINavigationBar.appearance().barTintColor = UIColor(Color("Panel"))
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    struct GroupName: View {
        @Binding var name: String
        
        var body: some View {
            VStack {
                TextHelper.text(key: "GroupName", alignment: .leading, type: .h2)
                
                TextField("", text: $name)
                    .padding(10)
                    .background(Color("Panel"))
                    .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .body))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
    
    struct EmojiSelector: View {
        @Binding var emoji: String
        
        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Emoji", alignment: .leading, type: .h2)
                
                EmojiTextField(text: $emoji)
                    .font(.system(size: 100))
                    .frame(width: 60, height: 60)
                    .background(Color("Panel"))
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
    struct GroupColor: View {
        @Binding var color: GroupBackgroundColor
        @State var selected = GroupBackgroundColor.one
        var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 4)
        
        var body: some View {
            VStack(alignment: .leading) {
                TextHelper.text(key: "Color", alignment: .leading, type: .h2)
                
                LazyVGrid(columns: items, spacing: 20) {
                    ForEach(GroupBackgroundColor.allCases, id: \.self) { color in
                        Circle()
                            .foregroundColor(color.getColor())
                            .frame(width: color == selected ? 40 : 50, height: color == selected ? 40 : 50, alignment: .center)
                            .animation(Animation.easeInOut, value: selected)
                            .onTapGesture {
                                withAnimation {
                                    selected = color
                                }
                            }
                    }
                }
                .padding()
                .background(Color("Panel"))
                .cornerRadius(16)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
    struct CreateButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        let viewModel: CreateGroupViewModel
        
        var body: some View {
            Button(action: {
                Task {
                    let didFinishSuccessfully = await viewModel.createGroup()
                    
                    if didFinishSuccessfully {
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
    
    struct ActivitySelector: View {
        @Binding var selectedActivities: [Activity]
        @Binding var group: UserGroup
        @State var showEditMenu = false
        var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
        let templates: [ActivityTemplate]
        
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
                            NavigationLink(destination: AddPage(activityList: $selectedActivities, template: template)) {
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
                    ForEach($selectedActivities.filter({ $0.wrappedValue.isEnabled })) { activity in
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
                    
                    NavigationLink(destination: ActivitySelector(selectedActivities: $selectedActivities, group: $group, templates: templates)) {
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

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
