//
//  GroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import SwiftUI

struct GroupOverview: View {
    let viewModel: GroupOverviewViewModel
    
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
                        
                        DaysAndTime(viewModel: viewModel)
                        
                        DaysForChallenges(viewModel: viewModel)
                        
                        UsersInGroup(users: viewModel.users)
                        
                        DeleteButton()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
    var body: some View {
        VStack(alignment: .leading) {
            TextHelper.text(key: "DeletingGroups", alignment: .leading, type: .h2)
            
            Button(action: {
                print("Delete")
            }, label: {
                TextHelper.text(key: "DeleteGroup", alignment: .center, type: .h2)
            })
            .padding()
            .frame(width: 150, height: 40, alignment: .leading)
            .background(Color("Delete"))
            .cornerRadius(16)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

struct UsersInGroup: View {
    @State var users: [User]
    
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

struct DaysAndTime: View {
    let dateHelper = DateHelper()
    @ObservedObject var viewModel: GroupOverviewViewModel
    
    @State var isPresented = false
    
    var body: some View {
        VStack {
            TextHelper.text(key: "ChallengeSettings", alignment: .leading, type: .h2)
            
            HStack(spacing: 25) {
                Group {
                    VStack {
                        Text(Localize.getString("ChallengesPerWeek"))
                            .font(Font.custom("Lexend-Regular", size: 16, relativeTo: .title2))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("Body"))
                        
                        ZStack {
                            Picker(selection: $viewModel.days, label: EmptyView()) {
                                ForEach(1...7, id: \.self) { number in
                                    Text(String(number))
                                }
                            }
                            .frame(width: 125, height: 40, alignment: .center)
                            .scaleEffect(3)
                            .labelsHidden()
                            
                            Text("\(viewModel.days)")
                                .font(Font.custom("Lexend-SemiBold", size: 30, relativeTo: .title2))
                                .frame(width: 200, height: 50, alignment: .center)
                                .background(Color("Panel"))
                                .userInteractionDisabled()
                        }
                    }
                    VStack {
                        Text(Localize.getString("DeliveryTime"))
                            .font(Font.custom("Lexend-Regular", size: 16, relativeTo: .title2))
                            .foregroundColor(Color("Body"))
                            .zIndex(1.0)
                        
                        ZStack {
                            DatePicker("", selection: $viewModel.time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 125)
                                .scaleEffect(1.6)
                            
                            Group {
                                Text(dateHelper.getHoursAndMinutes(date: viewModel.time))
                                    .font(Font.custom("Lexend-SemiBold", size: 30, relativeTo: .title2)) +
                                Text(" ") +
                                Text(dateHelper.getAmPm(date: viewModel.time))
                                    .font(Font.custom("Lexend-SemiBold", size: 20, relativeTo: .title2))
                            }
                            .frame(width: 200, height: 200, alignment: .center)
                            .background(Color("Panel"))
                            .userInteractionDisabled()
                        }
                        .background(Color("Panel"))
                    }
                }
                .frame(height: 75, alignment: .center)
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color("Panel"))
                .cornerRadius(15)
            }
        }
        .padding(.horizontal)
    }
}
