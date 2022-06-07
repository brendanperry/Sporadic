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
                        
                        YourActivities(activities: [
                            Activity(id: UUID(), isEnabled: true, maxValue: 10, minValue: 1, minRange: 0.25, name: "Run", templateId: 0, unit: "miles")
                        ])
                        
                        DaysAndTime(viewModel: viewModel)
                        
                        DaysForChallenges(viewModel: viewModel)
                        
                        UsersInGroup(users: [
                            User(recordId: NSObject(), name: "Nic Cage", photo: "nic"),
                            User(recordId: NSObject(), name: "Nic Cage", photo: "nic"),
                            User(recordId: NSObject(), name: "Nic Cage", photo: "nic"),
                            User(recordId: NSObject(), name: "Nic Cage", photo: "nic"),
                            User(recordId: NSObject(), name: "Nic Cage", photo: "nic")
                        ])
                        
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
            UINavigationBar.appearance().barTintColor = UIColor(viewModel.group.backgroundColor.getColor())
        }
    }
    
    func groupHeader() -> some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 75, height: 75, alignment: .leading)
                    .foregroundColor(viewModel.group.backgroundColor.getColor())
                
                Text(viewModel.group.emoji)
                    .font(.system(size: 40))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top)
    }
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image("BackButton")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20, alignment: .leading)
        })
        .buttonStyle(ButtonPressAnimationStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct YourActivities: View {
    let textHelper = TextHelper()
    let activities: [Activity]
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "GroupActivities", alignment: .leading, type: .h2)
            
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
                            
                            textHelper.GetTextByType(key: "Run", alignment: .center, type: .activityTitle, color: .white)
                                .padding(.bottom)
                            
                            textHelper.GetTextByType(key: "\(activity.minValue) - \(activity.maxValue) mi", alignment: .center, type: .body, color: .white)
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
                }
            }
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

struct DeleteButton: View {
    let textHelper = TextHelper()
    
    var body: some View {
        VStack(alignment: .leading) {
            textHelper.GetTextByType(key: "DeletingGroups", alignment: .leading, type: .h2)
            
            Button(action: {
                print("Delete")
            }, label: {
                textHelper.GetTextByType(key: "DeleteGroup", alignment: .center, type: .h2)
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
    let textHelper = TextHelper()
    @State var users: [User]
    
    init(users: [User]) {
        self.users = users
        
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "PeopleInGroup", alignment: .leading, type: .h2)
            
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(users) { user in
                        HStack {
                            Image("nic")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .leading)
                                .cornerRadius(100)
                            
                            textHelper.GetTextByType(key: user.name, alignment: .leading, type: .h2)
                        }
                    }
                    .padding(12)
                }
            }
            .frame(height: 250)
            .padding(12)
            .background(Color("Panel"))
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

struct DaysForChallenges: View {
    let textHelper = TextHelper()
    @ObservedObject var viewModel: GroupOverviewViewModel
    let daysInTheWeek = ["Su", "Mo", "Tu", "Th", "We", "Fr", "Sa"]
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "PotentialDays", alignment: .leading, type: .h2)
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
                            textHelper.GetTextByType(key: day, alignment: .center, type: .h2, color: .white)
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
    let textHelper = TextHelper()
    @ObservedObject var viewModel: GroupOverviewViewModel
    
    @State var isPresented = false
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "ChallengeSettings", alignment: .leading, type: .h2)
            
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
