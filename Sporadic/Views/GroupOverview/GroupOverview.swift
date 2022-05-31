//
//  GroupView.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/25/22.
//

import SwiftUI

struct GroupOverview: View {
    let viewModel = GroupOverviewViewModel()
//    @FetchRequest(
//        sortDescriptors: [SortDescriptor(\.name)],
//        predicate: NSPredicate(format: "isEnabled = true AND "))
//    var activities: FetchedResults<Activity>
    
    let textHelper = TextHelper()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                textHelper.GetTextByType(key: "Settings", alignment: .leading, type: .title)
                    .padding()
                
                DaysAndTime(viewModel: viewModel)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
    }
}

struct DaysAndTime: View {
    let dateHelper = DateHelper()
    @ObservedObject var viewModel: GroupOverviewViewModel
    
    @State var isPresented = false
    
    var body: some View {
        HStack(spacing: 25) {
            Group {
                VStack {
                    Text("Weekly\nNotifications")
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

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupOverview()
    }
}
