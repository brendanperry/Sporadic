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
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    
    init(viewModel: GroupOverviewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 35) {
                        groupHeader()
                        
                        YourActivities(activities: viewModel.activities)
                        
                        DaysAndTime(days: $viewModel.days, time: $viewModel.time)
                        
                        DaysForChallenges(viewModel: viewModel)
                        
                        UsersInGroup(users: viewModel.users)
                        
                        DeleteButton(viewModel: viewModel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("\(viewModel.group.name)")
        .navigationBarItems(leading: BackButton())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .onAppear {
            UINavigationBar.appearance().barTintColor = UIColor(GroupBackgroundColor.init(rawValue: viewModel.group.backgroundColor)?.getColor() ?? .red)
        }
        .task {
            await viewModel.getActivities()
            await viewModel.getUsers()
        }
    }
    
    func groupHeader() -> some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 75, height: 75, alignment: .leading)
                    .foregroundColor(GroupBackgroundColor.init(rawValue: viewModel.group.backgroundColor)?.getColor())
                
                Text(viewModel.group.emoji)
                    .font(.system(size: 40))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top)
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
        }
    }
}

struct YourActivities: View {
    let activities: [Activity]
    
    var body: some View {
        VStack {
            TextHelper.text(key: "GroupActivities", alignment: .leading, type: .h2)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(activities) { activity in
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .foregroundColor(.white)
                                
                                Image("Bike")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                            }
                            
                            TextHelper.text(key: "Run", alignment: .center, type: .activityTitle, color: .white)
                                .padding(.bottom)
                            
                            TextHelper.text(key: "\(activity.minValue) - \(activity.maxValue) mi", alignment: .center, type: .body, color: .white)
                                .opacity(0.75)
                        }
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(16)
                        .padding()
                    }
                    .padding(10)
                    
                    Image("Custom Plus")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(.blue)
                        .padding(5)
                        .background(Circle().foregroundColor(.white))
                        .padding(15)
                        .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.purple))
                        .padding()
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
                        Image("nic")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .leading)
                            .cornerRadius(100)
                        
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
    @ObservedObject var viewModel: GroupOverviewViewModel
    let daysInTheWeek = ["Su", "Mo", "Tu", "Th", "We", "Fr", "Sa"]
    
    var body: some View {
        VStack {
            TextHelper.text(key: "PotentialDays", alignment: .leading, type: .h2)
                .padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(daysInTheWeek, id: \.self) { day in
                        Button(action: {
                            if viewModel.daysInTheWeek.contains(day) {
                                viewModel.daysInTheWeek.removeAll(where: { $0 == day })
                            }
                            else {
                                viewModel.daysInTheWeek.append(day)
                            }
                            
                            print(viewModel.daysInTheWeek)
                        }, label: {
                            TextHelper.text(key: day, alignment: .center, type: .h2, color: .white)
                                .padding()
                                .background(Circle().foregroundColor(Color("DaySelection")))
                                .opacity(viewModel.daysInTheWeek.contains(day) ? 1 : 0.25)
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
