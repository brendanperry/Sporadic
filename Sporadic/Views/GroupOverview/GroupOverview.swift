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
                        
                        UsersInGroup(viewModel: viewModel, group: group)
                            .alert(isPresented: $viewModel.showError) {
                                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
                            }
                                                
                        DaysForChallenges(availableDays: $group.displayedDays, isOwner: viewModel.isOwner)
                        
                        DeliveryTime(isOwner: viewModel.isOwner, time: $group.deliveryTime)

                        if viewModel.isOwner {
                            DeleteButton(group: group, groups: $groups, viewModel: viewModel)
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
                    TextHelper.text(key: "Cancel", alignment: .center, type: .h5, color: .white)
                        .padding()
                        .background(Color("Failed"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
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
                    .foregroundColor(Color("Panel")).shadow(radius: GlobalSettings.shared.shadowRadius)
                    .ignoresSafeArea(.all, edges: .bottom)
            )
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
                        EditIcon()
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
                    .shadow(radius: GlobalSettings.shared.shadowRadius)
                    .padding(.leading)
                }
                else {
                    ForEach($group.activities) { activity in
                        NavigationLink(destination: EditActivity(activity: activity)) {
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .foregroundColor(.white)
                                    
                                    Image(activity.wrappedValue.templateId == nil ? "Custom Activity Icon Circle" : activity.wrappedValue.name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
//                                                .foregroundColor(activity.wrappedValue.template?.color ?? Color("Panel"))
                                        )
                                }
                                
                                TextHelper.text(key: activity.wrappedValue.name, alignment: .center, type: .h3)
                                    .padding(.top)
                                
                                TextHelper.text(key: "\(activity.wrappedValue.minValue) - \(activity.wrappedValue.maxValue)", alignment: .center, type: .h7)
                                    .frame(width: 60)
                                    .opacity(0.75)
                                
                                TextHelper.text(key: "\(activity.wrappedValue.unit.toAbbreviatedString())", alignment: .center, type: .h7)
                                    .opacity(0.75)
                            }
                            .padding()
                            .background(Color("Panel"))
                            .cornerRadius(10)
                            .shadow(radius: GlobalSettings.shared.shadowRadius)
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
                        PlusButton(backgroundColor: Color("Panel"))
                    })
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
        }
        .popover(isPresented: $showAddView) {
            NavigationStack {
                ActivitySelector(selectedActivities: $group.activities)
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
    
    var body: some View {
        VStack(alignment: .leading) {
            TextHelper.text(key: "Delete Group", alignment: .leading, type: .h4)
                .alert(isPresented: $showDeleteFailure) {
                    Alert(title: Text("Network Error"), message: Text("Could not delete group. Please check your connection and try again!"))
                }
            
            Button(action: {
                DispatchQueue.main.async {
                    showDeleteConfirmation = true
                }
            }, label: {
                HStack {
                    Text("Delete")
                        .foregroundColor(.white)
                        .font(Font.custom("Lexend-SemiBold", size: 18, relativeTo: .title3))
                        .padding()
                        .padding(.horizontal)
                        .background(Color("Failed"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                    
                    Spacer()
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
    }
}

struct UsersInGroup: View {
    @ObservedObject var viewModel: GroupOverviewViewModel
    @ObservedObject var group: UserGroup
    
    var body: some View {
        VStack {
            TextHelper.text(key: "PeopleInGroup", alignment: .leading, type: .h4)
            
            VStack(spacing: 0) {
                if !group.areUsersLoading {
                    ForEach(group.users) { user in
                        HStack {
                            Image(uiImage: user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50, alignment: .leading)
                                .cornerRadius(100)
                                .shadow(radius: GlobalSettings.shared.shadowRadius)
                            
                            TextHelper.text(key: user.name, alignment: .leading, type: .h5)
                        }
                    }
                    .padding(12)
                }
                else {
                    HStack {
                        Circle()
                            .frame(width: 50, height: 50, alignment: .leading)
                            .foregroundColor(.white)
                            .shadow(radius: GlobalSettings.shared.shadowRadius)
                        
                        LoadingBar()
                            .frame(height: 20)
                    }
                    .padding(12)
                }
                
                ShareLink(item: "https://sporadic.app/?group=\(group.record.recordID.recordName)", message: Text("Join \(group.name) on Sporadic!"), label: {
                    Text("Invite Friends")
                        .font(.custom("Lexend-Regular", size: 12))
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
