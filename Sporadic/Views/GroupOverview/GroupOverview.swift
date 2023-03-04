//
//  GroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import SwiftUI

struct GroupOverview: View {
    @StateObject var viewModel = GroupOverviewViewModel()
    @Binding var group: UserGroup
    @Binding var groups: [UserGroup]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 35) {
                        GroupHeader(name: $group.name, emoji: $viewModel.emoji, color: $group.backgroundColor, isOwner: viewModel.isOwner)
                        
                        YourActivities(group: $group, viewModel: viewModel)

                        StreakAndTime(isOwner: viewModel.isOwner, time: $group.deliveryTime)

                        DaysForChallenges(availableDays: $group.displayedDays, isOwner: viewModel.isOwner)

                        UsersInGroup(viewModel: viewModel, group: $group)
                            .alert(isPresented: $viewModel.showError) {
                                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
                            }

                        if viewModel.isOwner {
                            DeleteButton(group: $group, groups: $groups, viewModel: viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, viewModel.isOwner ? 100 : 20)
                }
                
                if viewModel.isOwner {
                    saveBar()
                }
            }
            
            if viewModel.isLoading  {
                LoadingIndicator()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(viewModel.toolbarColor, for: .navigationBar)
        .navigationTitle("\(group.name)")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .onChange(of: group.backgroundColor) { _ in
            viewModel.updateToolbarColor(color: GroupBackgroundColor(rawValue: group.backgroundColor) ?? .one)
        }
        .task {
            viewModel.emoji = group.emoji
            viewModel.updateToolbarColor(color: GroupBackgroundColor(rawValue: group.backgroundColor) ?? .one)
            await viewModel.checkOwnership(group: group)
        }
    }
    
    func saveBar() -> VStack<TupleView<(Spacer, some View)>> {
        return VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    TextHelper.text(key: "Cancel", alignment: .center, type: .h2)
                        .padding()
                        .frame(width: 150, height: 40, alignment: .leading)
                        .background(Color("Delete"))
                        .cornerRadius(16)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.save(group: group) { didComplete in
                        if didComplete {
                            DispatchQueue.main.async {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }, label: {
                    TextHelper.text(key: "Save", alignment: .center, type: .h2, color: .white)
                        .padding()
                        .frame(width: 150, height: 40, alignment: .leading)
                        .background(Color("Primary"))
                        .cornerRadius(16)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .padding()
                .onChange(of: viewModel.itemsCompleted) { newValue in
                    if newValue == 4 {
                        viewModel.isLoading = false
                        dismiss()
                    }
                }
                
                Spacer()
            }
            .background(Rectangle().foregroundColor(Color("Panel")).shadow(radius: 3))
            .ignoresSafeArea(.all, edges: .bottom)
        }
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
        @State var showEdit = false
        let isOwner: Bool
        
        var body: some View {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 75, height: 75, alignment: .leading)
                        .foregroundColor(GroupBackgroundColor.init(rawValue: color)?.getColor())
                    
                    Text(emoji)
                        .font(.system(size: 40))
                    
                    if isOwner {
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
                .disabled(!isOwner)
                .onTapGesture {
                    showEdit = true
                }
                .popover(isPresented: $showEdit) {
                    EditGroupHeader(name: $name, emoji: $emoji, color: $color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top)
        }
    }
}

struct YourActivities: View {
    @Binding var group: UserGroup
    @ObservedObject var viewModel: GroupOverviewViewModel
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 3)

    @State var showEdit = false
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Activities", alignment: .leading, type: .h2)
            
            LazyVGrid(columns: items, spacing: 17) {
                    if group.areActivitiesLoading {
                        VStack(spacing: 0) {
                            Circle()
                                .frame(width: 50, height: 50, alignment: .center)
                                .foregroundColor(.white)

                            LoadingBar()
                                .frame(height: 15)
                                .padding(.vertical)
                        }
                        .frame(height: 125)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .background(Color.purple)
                        .cornerRadius(16)
                        .shadow(radius: 3)
                        .padding(.leading)
                    }
                    else {
                        ForEach($group.activities, id: \.wrappedValue.record.recordID) { activity in
                            NavigationLink(destination: EditActivity(activity: activity)) {
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
                                .padding()
                                .background(Color("Panel"))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                            .id(UUID())
                            .disabled(!viewModel.isOwner)
                        }
                        .padding(.vertical, 1)
                    }
                    
                    if viewModel.isOwner {
                        NavigationLink(destination: ActivitySelector(selectedActivities: $group.activities, showEditMenu: true), label: {
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
                        .id(UUID())
                    }
            }
        }
        .padding(.horizontal)
    }
}

struct DeleteButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showDeleteConfirmation = false
    @State var showDeleteFailure = false
    @Binding var group: UserGroup
    @Binding var groups: [UserGroup]
    let viewModel: GroupOverviewViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            TextHelper.text(key: "DeletingGroups", alignment: .leading, type: .h2)
                .alert(isPresented: $showDeleteFailure) {
                    Alert(title: Text("Network Error"), message: Text("Could not delete group. Please check your connection and try again!"))
                }
            
            Button(action: {
                DispatchQueue.main.async {
                    showDeleteConfirmation = true
                }
            }, label: {
                TextHelper.text(key: "DeleteGroup", alignment: .center, type: .h2)
                    .padding()
                    .frame(width: 150, height: 40, alignment: .leading)
                    .background(Color("Delete"))
                    .cornerRadius(16)
            })
            .buttonStyle(ButtonPressAnimationStyle())
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(title: Text("Delete \(group.name)?"), message: Text("Are you sure you want to delete this group? It cannot be undone."),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteGroup(group: group) {
                        if $0 == true {
                            group.wasDeleted = true
                            groups.removeAll(where: { $0.record.recordID == group.record.recordID })
                            presentationMode.wrappedValue.dismiss()
                        }
                        else {
                            showDeleteFailure = true
                        }
                        
                        print("Delete Group Finished With Status: \($0)")
                    }
                })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

struct UsersInGroup: View {
    @ObservedObject var viewModel: GroupOverviewViewModel
    @Binding var group: UserGroup
    
    var body: some View {
        VStack {
            TextHelper.text(key: "PeopleInGroup", alignment: .leading, type: .h2)
            
            VStack(spacing: 0) {
                if !group.areUsersLoading {
                    ForEach(group.users) { user in
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
                else {
                    HStack {
                        Circle()
                            .frame(width: 50, height: 50, alignment: .leading)
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                        
                        LoadingBar()
                            .frame(height: 20)
                    }
                    .padding(12)
                }
                
                ShareLink(item: "https://sporadic.app/?group=\(group.record.recordID.recordName)", message: Text("Join \(group.name) on Sporadic!"), label: {
                    TextHelper.text(key: "Invite New Members", alignment: .center, type: .h2, color: .white)
                        .padding()
                        .background(Color("Primary"))
                        .cornerRadius(16)
                        .padding()
                })
                .buttonStyle(ButtonPressAnimationStyle())
            }
            .padding(12)
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

struct DaysForChallenges: View {
    @Binding var availableDays: [Int]
    let daysInTheWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    let isOwner: Bool
    
    var body: some View {
        VStack {
            TextHelper.text(key: "DaysToGetChallenge", alignment: .leading, type: .h2)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(daysInTheWeek, id: \.self) { day in
                        Button(action: {
                            if availableDays.contains(dayToInt(day)) {
                                availableDays.removeAll(where: { $0 == dayToInt(day) })
                            }
                            else {
                                availableDays.append(dayToInt(day))
                            }
                        }, label: {
                            TextHelper.text(key: day, alignment: .center, type: .h2, color: .white)
                                .padding()
                                .background(Circle().foregroundColor(Color("DaySelection")))
                                .opacity(availableDays.contains(dayToInt(day)) ? 1 : 0.25)
                                .foregroundColor(availableDays.contains(dayToInt(day)) ? .red : .blue)
                                .shadow(radius: 3)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .disabled(!isOwner)
                    }
                }
                .padding()
            }
            .background(Color("Panel"))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    // TODO: Move this elsewhere
    func dayToInt(_ day: String) -> Int {
        switch day {
        case "Su": return 1
        case "Mo": return 2
        case "Tu": return 3
        case "We": return 4
        case "Th": return 5
        case "Fr": return 6
        case "Sa": return 7
        default: return -1
        }
    }
}
