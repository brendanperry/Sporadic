//
//  GroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import SwiftUI

struct GroupOverview: View {
    @ObservedObject var viewModel: GroupOverviewViewModel
    
    let textHelper = TextHelper()
    let reloadAction: (Bool) -> Void
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    @Environment(\.isPresented) var isPresented
    
    init(viewModel: GroupOverviewViewModel, reloadAction: @escaping (Bool) -> Void) {
        self.viewModel = viewModel
        self.reloadAction = reloadAction
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 35) {
                        GroupHeader(name: $viewModel.group.name, emoji: $viewModel.emoji, color: $viewModel.group.backgroundColor)
                        
                        YourActivities(viewModel: viewModel)
                        
                        DaysAndTime(days: $viewModel.group.daysPerWeek, time: $viewModel.group.deliveryTime)
                        
                        DaysForChallenges(daysOfTheWeek: $viewModel.group.daysOfTheWeek)
                        
                        UsersInGroup(users: viewModel.users)
                        
                        DeleteButton(viewModel: viewModel, reloadAction: reloadAction)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
            }
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("\(viewModel.group.name)")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               BackButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .onAppear {
            UINavigationBar.appearance().barTintColor = UIColor(GroupBackgroundColor.init(rawValue: viewModel.group.backgroundColor)?.getColor() ?? .red)
        }
        .onChange(of: isPresented) { newValue in
            if newValue == false {
                saveIfThereAreChanges()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { output in
            saveIfThereAreChanges()
         })
    }
    
    func saveIfThereAreChanges() {
        viewModel.saveGroup()
    }
    
    struct EditGroupHeader: View {
        @Binding var name: String
        @Binding var emoji: String
        @Binding var color: Int
        
        var body: some View {
            ZStack {
                Image("BackgroundImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical) {
                    VStack(spacing: 35) {
                        GroupName(name: $name)
                        
                        EmojiSelector(emoji: $emoji)
                        
                        GroupColor(selected: $color)
                    }
                    .padding(.top, 50)
                }
            }
        }
    }
    
    struct GroupHeader: View {
        @Binding var name: String
        @Binding var emoji: String
        @Binding var color: Int
        
        var body: some View {
            VStack {
                NavigationLink(destination: EditGroupHeader(name: $name, emoji: $emoji, color: $color)) {
                    ZStack {
                        Circle()
                            .frame(width: 75, height: 75, alignment: .leading)
                            .foregroundColor(GroupBackgroundColor.init(rawValue: color)?.getColor())
                        
                        Text(emoji)
                            .font(.system(size: 40))
                        
                        Image("Edit Group Icon")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .center)
                            .background(
                                Circle()
                                    .foregroundColor(Color("EditProfile"))
                                    .frame(width: 25, height: 25, alignment: .center)
                                    .offset(x: -1, y: -1)
                            )
                            .offset(x: 25, y: -25)
                    }
                }
                .buttonStyle(ButtonPressAnimationStyle())
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top)
        }
    }
}

struct YourActivities: View {
    @ObservedObject var viewModel: GroupOverviewViewModel
    
    var body: some View {
        VStack {
            TextHelper.text(key: "GroupActivities", alignment: .leading, type: .h2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach($viewModel.activities.filter({ $0.wrappedValue.isEnabled})) { activity in
                        NavigationLink(destination: EditActivity(activityList: $viewModel.activities, activity: activity)) {
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .foregroundColor(.white)
                                    
                                    Image(activity.wrappedValue.templateId == nil ? "Custom Activity Icon Circle" : activity.wrappedValue.name + " Circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .center)
                                }
                                
                                TextHelper.text(key: activity.wrappedValue.name, alignment: .center, type: .activityTitle, color: .white)
                                    .padding(.bottom)
                                
                                TextHelper.text(key: "\(activity.wrappedValue.minValue) - \(activity.wrappedValue.maxValue)", alignment: .center, type: .body, color: .white)
                                    .frame(width: 60)
                                    .opacity(0.75)
                                
                                TextHelper.text(key: "\(activity.wrappedValue.unit.toAbbreviatedString())", alignment: .center, type: .body, color: .white)
                                    .opacity(0.75)
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .background(Color.purple)
                            .cornerRadius(16)
                            .shadow(radius: 3)
                            .padding(.leading)
                        }
                    }
                    .padding(.vertical, 1)
                    
                    NavigationLink(destination: ActivitySelector(selectedActivities: $viewModel.activities, showEditMenu: true, afterAddAction: {
                        viewModel.saveActivities()
                    }), label: {
                        Image("Custom Plus")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.blue)
                            .padding(5)
                            .background(Circle().foregroundColor(.white))
                            .padding(15)
                            .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.purple))
                            .shadow(radius: 3)
                            .padding()
                    })
                }
                .frame(minHeight: 175)
            }
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

struct DeleteButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showDeleteConfirmation = false
    let viewModel: GroupOverviewViewModel
    let reloadAction: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            TextHelper.text(key: "DeletingGroups", alignment: .leading, type: .h2)
            
            Button(action: {
                showDeleteConfirmation = true
            }, label: {
                TextHelper.text(key: "DeleteGroup", alignment: .center, type: .h2)
                    .padding()
                    .frame(width: 150, height: 40, alignment: .leading)
                    .background(Color("Delete"))
                    .cornerRadius(16)
                    .padding(.bottom)
            })
            .buttonStyle(ButtonPressAnimationStyle())
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(title: Text("Delete \(viewModel.group.name)?"), message: Text("Are you sure you want to delete this group? It cannot be undone."),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteGroup() { didFinishSuccessfully in
                        if didFinishSuccessfully {
                            reloadAction(false)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

struct UsersInGroup: View {
    let users: [User]
    
    init(users: [User]) {
        self.users = users
        
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            TextHelper.text(key: "PeopleInGroup", alignment: .leading, type: .h2)
            
            VStack(spacing: 0) {
                ForEach(users) { user in
                    HStack {
                        Image(uiImage: user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50, alignment: .leading)
                            .cornerRadius(100)
                            .shadow(radius: 3)
                        
                        TextHelper.text(key: user.name, alignment: .leading, type: .h2)
                    }
                }
                .padding(12)
            }
            .padding(12)
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

struct DaysForChallenges: View {
    @Binding var daysOfTheWeek: [String]
    let daysInTheWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    
    var body: some View {
        VStack {
            TextHelper.text(key: "PotentialDays", alignment: .leading, type: .h2)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(daysInTheWeek, id: \.self) { day in
                        Button(action: {
                            if daysOfTheWeek.contains(day) {
                                daysOfTheWeek.removeAll(where: { $0 == day })
                            }
                            else {
                                daysOfTheWeek.append(day)
                            }
                        }, label: {
                            TextHelper.text(key: day, alignment: .center, type: .h2, color: .white)
                                .padding()
                                .background(Circle().foregroundColor(Color("DaySelection")))
                                .opacity(daysOfTheWeek.contains(day) ? 1 : 0.25)
                                .foregroundColor(daysOfTheWeek.contains([day]) ? .red : .blue)
                                .shadow(radius: 3)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                    }
                }
                .padding()
            }
            .background(Color("Panel"))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}
