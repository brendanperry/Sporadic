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
                    VStack {
                        groupHeader()
                        
                        YourActivities(activities: [
                            Activity(id: UUID(), isEnabled: true, maxValue: 10, minValue: 1, minRange: 0.25, name: "Run", templateId: 0, unit: "miles")
                        ])
                        
                        DaysAndTime(viewModel: viewModel)
                            .padding()
                        
                        DaysForChallenges(viewModel: viewModel)
                        
                        UsersInGroup(users: [
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
        .padding()
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
                .frame(width: 30, height: 30, alignment: .leading)
        })
        .buttonStyle(ButtonPressAnimationStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct YourActivities: View {
    let textHelper = TextHelper()
    let activities: [Activity]
    
    var body: some View {
        textHelper.GetTextByType(key: "GroupActivities", alignment: .leading, type: .challengeAndSettings)
            .padding(.horizontal)
        
        ScrollView(.horizontal) {
            HStack {
                ForEach(activities) { activity in
                    VStack {
                        ZStack {
                            Circle()
                                .frame(width: 45, height: 45, alignment: .center)
                            
                            Image("nic")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                        }
                        
                        textHelper.GetTextByType(key: "Run", alignment: .center, type: .h2)
                            .padding(.bottom)
                        
                        textHelper.GetTextByType(key: "\(activity.minValue) - \(activity.maxValue) mi", alignment: .center, type: .challengeGroup)
                    }
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(16)
                    .padding()
                }
                
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Circle().foregroundColor(.white))
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.purple))
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding([.horizontal, .bottom])
    }
}

struct DeleteButton: View {
    let textHelper = TextHelper()

    var body: some View {
        VStack(alignment: .leading) {
            textHelper.GetTextByType(key: "DeleteCannotBeUndone", alignment: .leading, type: .h3)
                .padding(.horizontal)
            
            Button(action: {
                print("Delete")
            }, label: {
                textHelper.GetTextByType(key: "Delete", alignment: .center, type: .h3)
            })
            .frame(width: 150)
            .padding()
            .background(Color.red)
            .cornerRadius(16)
            .padding()
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            textHelper.GetTextByType(key: "PeopleInGroup", alignment: .leading, type: .h3)
                .padding(.horizontal)
            
            List {
                ForEach(users) { user in
                    HStack {
                        Image("nic")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .leading)
                            .cornerRadius(100)
                        
                        textHelper.GetTextByType(key: user.name, alignment: .leading, type: .body)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.white)
                }
                .onDelete(perform: delete)
            }
            .background(Color.clear)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    func delete(at offsets: IndexSet) {
        users.remove(atOffsets: offsets)
    }
}

struct DaysForChallenges: View {
    let textHelper = TextHelper()
    @ObservedObject var viewModel: GroupOverviewViewModel
    let daysInTheWeek = ["Su", "Mo", "Tu", "Th", "We", "Fr", "Sa"]
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "PotentialDays", alignment: .leading, type: .body)
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
                            textHelper.GetTextByType(key: day, alignment: .center, type: .body)
                                .padding()
                                .background(Circle().foregroundColor(viewModel.daysInTheWeek.contains(day) ? .blue : .gray))
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                    }
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding()
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
            textHelper.GetTextByType(key: "Challenge Settings", alignment: .leading, type: .h3)
                .padding([.horizontal, .bottom])
            
            HStack(spacing: 25) {
                Group {
                    VStack {
                        Text("ChallengesPerWeek")
                            .frame(height: 50)
                            .multilineTextAlignment(.center)
                            .font(Font.custom("Gilroy", size: 18, relativeTo: .title3))
                            .foregroundColor(Color("SettingButtonTextColor"))
                            .offset(y: 10)
                        
                        ZStack {
                            Picker(selection: $viewModel.days, label: EmptyView()) {
                                ForEach(1...7, id: \.self) { number in
                                    Text(String(number))
                                }
                            }
                            .frame(width: 125, height: 50, alignment: .center)
                            .labelsHidden()
                            
                            Text("\(viewModel.days)")
                                .font(Font.custom("Gilroy", size: 34, relativeTo: .title2))
                                .frame(width: 200, height: 50, alignment: .center)
                                .background(Color("ActivityBackgroundColor"))
                                .userInteractionDisabled()
                        }
                    }
                    VStack {
                        Text("Delivery Time")
                            .font(Font.custom("Gilroy", size: 18, relativeTo: .title3))
                            .foregroundColor(Color("SettingButtonTextColor"))
                            .zIndex(1.0)
                        
                        ZStack {
                            DatePicker("", selection: $viewModel.time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 125)
                                .scaleEffect(1.6)
                            
                            Group {
                                Text(dateHelper.getHoursAndMinutes(date: viewModel.time))
                                    .font(Font.custom("Gilroy", size: 34, relativeTo: .title2)) +
                                Text(" ") +
                                Text(dateHelper.getAmPm(date: viewModel.time))
                                    .font(Font.custom("Gilroy", size: 22, relativeTo: .title2))
                            }
                            .frame(width: 200, height: 200, alignment: .center)
                            .background(Color("ActivityBackgroundColor"))
                            .userInteractionDisabled()
                        }
                        .background(Color("ActivityBackgroundColor"))
                        .padding(.top, 1)
                    }
                }
                .frame(height: 75, alignment: .center)
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color("ActivityBackgroundColor"))
                .cornerRadius(15)
            }
        }
    }
}

//struct GroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupOverview(viewModel: )
//    }
//}
