//
//  GroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import SwiftUI

struct GroupOverview: View {
    @StateObject var viewModel = GroupOverviewViewModel()
    @ObservedObject var group: UserGroup
    @Binding var groups: [UserGroup]
    
    let updateNextChallengeText: () -> Void
    let hardRefresh: () -> Void
    
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
                    VStack(spacing: GlobalSettings.shared.controlSpacing) {
                        GroupHeader(name: $group.name, emoji: $viewModel.emoji, color: $group.backgroundColor, isOwner: viewModel.isOwner)
                        
                        YourActivities(group: group, viewModel: viewModel)
                        
                        UsersInGroup(viewModel: viewModel, group: group, groups: $groups)
                            .alert(isPresented: $viewModel.showError) {
                                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
                            }
                                                
                        DaysForChallenges(availableDays: $group.displayedDays, isOwner: viewModel.isOwner)
                        
                        DeliveryTime(isOwner: viewModel.isOwner, time: $group.deliveryTime)

                        if viewModel.isOwner {
                            DeleteButton(group: group, groups: $groups, viewModel: viewModel, loadNextChallengeText: updateNextChallengeText)
                        }
                    }
                    .padding(.horizontal)
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
        .toolbarBackground(.visible, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .toolbar {
            if !viewModel.isOwner {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(showBackground: false)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("\(group.name)")
                    .font(.headline)
                    .foregroundColor(Color("Gray400"))
            }
        }
        .onAppear {
            viewModel.checkOwnership(group: group)
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.red ]
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.red ]
        }
        .onChange(of: group.backgroundColor) { _ in
            viewModel.updateToolbarColor(color: GroupBackgroundColor(rawValue: group.backgroundColor) ?? .one)
        }
        .task {
            viewModel.emoji = group.emoji
            viewModel.updateToolbarColor(color: GroupBackgroundColor(rawValue: group.backgroundColor) ?? .one)
        }
    }
    
    func saveBar() -> VStack<TupleView<(Spacer, some View)>> {
        return VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    viewModel.removeUnsavedActivities(group: group)
                    hardRefresh()
                    dismiss()
                }, label: {
                    TextHelper.text(key: "Cancel", alignment: .center, type: .h5, color: Color("CancelText"))
                        .padding()
                        .background(Color("Cancel"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.save(group: group) { didComplete in
                        if didComplete {
                            DispatchQueue.main.async {
                                updateNextChallengeText()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }, label: {
                    TextHelper.text(key: "Save", alignment: .center, type: .h5, color: .white)
                        .padding()
                        .background(Color("BrandPurple"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
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
            .background(
                Rectangle()
                    .foregroundColor(Color("Navigation"))
                    .background(.thinMaterial)
                    .shadow(color: Color("Shadow"), radius: 16, x: 0, y: -4)
                    .ignoresSafeArea(.all, edges: .bottom)
            )
        }
    }
    
    struct EditGroupHeader: View {
        @Binding var name: String
        @Binding var emoji: String
        @Binding var color: Int
        @Binding var showEdit: Bool
        
        var body: some View {
            ZStack {
                Image("BackgroundImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        Spacer()
                        
                        VStack(spacing: 35) {
                            GroupName(name: $name)
                            
                            EmojiSelector(emoji: $emoji)
                            
                            GroupColor(selected: $color)
                        }
                        .padding(.top, 100)
                    }
                    .padding()
                    
                    CloseButton(shouldShow: $showEdit)
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
                        EditIcon()
                            .offset(x: 25, y: -25)
                    }
                }
                .buttonStyle(ButtonPressAnimationStyle())
                .disabled(!isOwner)
                .onTapGesture {
                    if isOwner {
                        showEdit = true
                    }
                }
                .popover(isPresented: $showEdit) {
                    EditGroupHeader(name: $name, emoji: $emoji, color: $color, showEdit: $showEdit)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top)
        }
    }
}

struct YourActivities: View {
    @ObservedObject var group: UserGroup
    @ObservedObject var viewModel: GroupOverviewViewModel
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 3)
    @State var showAddView = false
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Exercises", alignment: .leading, type: .h4)
            
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
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                    .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                    .padding(.leading)
                }
                else {
                    ForEach($group.activities.filter({ !$0.wrappedValue.wasDeleted })) { activity in
                        NavigationLink(destination: EditActivity(activity: activity, activities: $group.activities)) {
                            SelectedActivity(activity: activity)
                        }
                        .id(UUID())
                        .disabled(!viewModel.isOwner)
                    }
                    .padding(.vertical, 1)
                }
                
                if viewModel.isOwner {
                    Button(action: {
                        showAddView = true
                    }, label: {
                        PlusButton(shape: Rectangle(), backgroundColor: Color("Panel"), lockLightMode: false, shadow: false)
                    })
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
        }
        .popover(isPresented: $showAddView) {
            NavigationStack {
                ActivitySelector(selectedActivities: $group.activities, shouldShow: $showAddView)
            }
        }
    }
}

struct DeleteButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showDeleteConfirmation = false
    @State var showDeleteFailure = false
    @ObservedObject var group: UserGroup
    @Binding var groups: [UserGroup]
    let viewModel: GroupOverviewViewModel
    
    let loadNextChallengeText: () -> Void
    
    var body: some View {
        ZStack {
            TextHelper.text(key: "", alignment: .leading, type: .h4)
                .alert(isPresented: $showDeleteFailure) {
                    Alert(title: Text("Network Error"), message: Text("Could not delete group. Please check your connection and try again!"))
                }
            
            HStack {
                Button(action: {
                    DispatchQueue.main.async {
                        showDeleteConfirmation = true
                    }
                }, label: {
                    HStack {
                        Text("Delete group")
                            .font(.custom("Lexend-Regular", size: 15))
                            .foregroundColor(Color("Failed"))
                    }
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
                                loadNextChallengeText()
                                presentationMode.wrappedValue.dismiss()
                            }
                            else {
                                showDeleteFailure = true
                            }
                            
                            print("Delete Group Finished With Status: \($0)")
                        }
                    })
                }
                
                Spacer()
            }
        }
    }
}

struct UsersInGroup: View {
    @ObservedObject var viewModel: GroupOverviewViewModel
    @ObservedObject var group: UserGroup
    @Binding var groups: [UserGroup]
    @Environment(\.dismiss) var dismiss
    @State var showLeave = false

    var body: some View {
        VStack {
            HStack {
                TextHelper.text(key: "PeopleInGroup", alignment: .leading, type: .h4)
                
                if !viewModel.isOwner {
                    Button(action: {
                        showLeave = true
                    }, label: {
                        TextHelper.text(key: "Leave", alignment: .trailing, type: .body, color: Color("Failed"))
                    })
                    .alert("Leave Group?", isPresented: $showLeave, actions: {
                        Button("Cancel", role: ButtonRole.cancel, action: {
                            showLeave = false
                        })
                        
                        Button("Leave", role: ButtonRole.destructive, action: {
                            viewModel.leaveGroup(group: group) { didLeave in
                                if didLeave {
                                    DispatchQueue.main.async {
                                        groups.removeAll(where: { $0.record.recordID == group.record.recordID })
                                        showLeave = false
                                        dismiss()
                                    }
                                }
                            }
                        })
                    }, message: {
                        Text("You can always join back later.")
                    })
                }
            }
            
            VStack(spacing: 0) {
                if !group.areUsersLoading {
                    ForEach(group.users) { user in
                        HStack {
                            Image(uiImage: user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(.infinity)

                            TextHelper.text(key: user.name, alignment: .leading, type: .h5)
                            
                            Spacer()
                            
                            if group.owner.recordID == user.record.recordID {
                                Image("Owner")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .padding(12)
                }
                else {
                    HStack {
                        Circle()
                            .frame(width: 50, height: 50, alignment: .leading)
                            .foregroundColor(.white)
                            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)

                        LoadingBar()
                            .frame(height: 20)
                    }
                    .padding(12)
                }
                
                ShareLink(item: "https://sporadic.app/?group=\(group.record.recordID.recordName)", message: Text("Join \(group.name) on Sporadic!"), label: {
                    Text("Invite Friends")
                        .font(.custom("Lexend-Regular", size: 15))
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .padding(.horizontal)
                        .background(Color("BrandPurple"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        .padding()
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        }
    }
}

struct DaysForChallenges: View {
    @Binding var availableDays: [Int]
    let isOwner: Bool
    
    var body: some View {
        VStack {
            TextHelper.text(key: "DaysToGetChallenge", alignment: .leading, type: .h4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(DaysForChallenge.allCases, id: \.rawValue) { day in
                        Button(action: {
                            if availableDays.contains(day.rawValue) {
                                availableDays.removeAll(where: { $0 == day.rawValue })
                            }
                            else {
                                availableDays.append(day.rawValue)
                            }
                        }, label: {
                            // W and M are larger letters and get more padding so I made the padding go off of W and hid the text
                            ZStack {
                                TextHelper.text(key: "W", alignment: .center, type: .h3, color: .clear)
                                    .padding()
                                    .background(
                                        Circle()
                                            .foregroundColor(availableDays.contains(day.rawValue) ? Color("BrandPurple") : Color("Gray150")))
                                    .opacity(availableDays.contains(day.rawValue) ? 1 : 0.80)
                                    .foregroundColor(.white)
                                
                                TextHelper.text(key: day.description, alignment: .center, type: .h3, color: .white)
                                    .foregroundColor(.white)
                            }
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .disabled(!isOwner)
                    }
                }
                .padding()
            }
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        }
    }
}
