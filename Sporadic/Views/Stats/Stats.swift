//
//  Stats.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/2/22.
//

import SwiftUI
import Charts
import CloudKit

struct Stats: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel: StatsViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @State var selectedGroup: UserGroup? = nil
    @State var selectedActivity = Activity(record: CKRecord(recordType: "Activity"), maxValue: 0, minValue: 0, name: "", unit: ActivityUnit.general)
    @FocusState var isPickerFocused: Bool
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    TextHelper.text(key: "Analytics", alignment: .leading, type: .h1)
                        .padding(.top, 50)
                        .padding(.bottom)
                        .onTapGesture {
                            isPickerFocused = true
                        }
                    
                    GroupPicker(selectedGroup: $selectedGroup, homeViewModel: homeViewModel)
                        .onChange(of: selectedGroup) { newValue in
                            if let group = newValue {
                                selectedActivity = group.activities.first ?? selectedActivity
                                
                                Task {
                                    await viewModel.loadCompletedChallenges(group: group)
                                }
                            }
                        }
                    
                    HStack(spacing: 20) {
                        ActivityPicker(selectedActivity: $selectedActivity, activities: selectedGroup?.activities ?? [])
                        
                        Streak(selectedGroup: selectedGroup)
                    }
                    
                    VStack (alignment: .leading) {
                        if viewModel.data.isEmpty {
                            TextHelper.text(key: "Not enough data to display.", alignment: .center, type: .body)
                                .padding()
                        }
                        else {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .padding()
                            
                            TextHelper.text(key: "\(Int(viewModel.total)) mi", alignment: .leading, type: .h3)
                                .padding(.horizontal)
                            
                            GroupChart(data: viewModel.data, groupColor: GroupBackgroundColor(rawValue: selectedGroup?.backgroundColor ?? 0)?.getColor() ?? Color.blue)
                        }
                    }
                    .background(Color("Panel"))
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                    .shadow(radius: GlobalSettings.shared.shadowRadius)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
                .preferredColorScheme(ColorSchemeHelper().getColorSceme())
                .padding(.top)
            }
            
            NavigationBar(viewRouter: viewRouter)
        }
    }
    
    struct GroupChart: View {
        let data: [CompletedChallenge]
        let groupColor: Color
        
        var body: some View {
            Chart(data) {
                LineMark(x: .value("Date", $0.date), y: .value($0.unit, $0.amount))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(groupColor)
                
                AreaMark(x: .value("Date", $0.date), y: .value($0.unit, $0.amount))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Gradient(colors: [groupColor, Color.clear]))
            }
            .chartXAxis {
                AxisMarks { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.defaultDigits).day().year(.twoDigits))
                                .font(Font.custom("Lexend-SemiBold", size: 11))
                                .foregroundColor(Color("Gray200"))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let amount = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(amount) \(ActivityUnit(rawValue: data.first?.unit ?? "")?.toAbbreviatedString() ?? "")")
                                .font(Font.custom("Lexend-SemiBold", size: 11))
                                .foregroundColor(Color("Gray200"))
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    struct GroupPicker: View {
        @Binding var selectedGroup: UserGroup?
        @ObservedObject var homeViewModel: HomeViewModel
        
        var body: some View {
            ZStack {
                HStack {
                    Text(selectedGroup?.emoji ?? "")
                        .font(.title)
                        .padding(10)
                        .background(Circle().foregroundColor(GroupBackgroundColor.init(rawValue: selectedGroup?.backgroundColor ?? 0)?.getColor()))
                    
                    Text(selectedGroup?.name ?? "Select Group")
                        .font(Font.custom("Lexend-SemiBold", size: 16, relativeTo: .title3))
                        .foregroundColor(Color("Gray300"))
                        .padding(.vertical)
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if !homeViewModel.groups.isEmpty {
                        selectedGroup = homeViewModel.groups.first
                    }
                }
                
                HStack(spacing: 0) {
                    Menu {
                        ForEach(0 ..< homeViewModel.groups.count) {
                            let index = $0
                            Button("\(homeViewModel.groups[index].name)") {
                                selectedGroup = homeViewModel.groups[index]
                            }
                        }
                    } label: {
                        Label("", image: "")
                            .labelStyle(TitleOnlyLabelStyle())
                            .frame(maxWidth: .infinity, maxHeight: 75)
                    }
                }
            }
        }
    }
    
    struct Streak: View {
        let selectedGroup: UserGroup?
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                
                Text("Current Streak")
                    .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .title3))
                    .foregroundColor(Color("Gray150"))
                
                TextHelper.text(key: "14", alignment: .leading, type: .h3)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                    .foregroundColor(Color("Panel"))
                    .shadow(radius: GlobalSettings.shared.shadowRadius)
            )
        }
    }
    
    struct ActivityPicker: View {
        @Binding var selectedActivity: Activity
        let activities: [Activity]
        
        var body: some View {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(selectedActivity.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.white)
                    }
                    
                    TextHelper.text(key: selectedActivity.name, alignment: .leading, type: .h3, color: Color("Gray150"))
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundColor(Color("Gray300"))
                        .shadow(radius: GlobalSettings.shared.shadowRadius)
                )
                
                HStack(spacing: 0) {
                    Menu {
                        ForEach(0 ..< activities.count) {
                            let index = $0
                            Button("\(activities[index].name)") {
                                selectedActivity = activities[index]
                            }
                        }
                    } label: {
                        Label("", image: "")
                            .labelStyle(TitleOnlyLabelStyle())
                            .frame(maxWidth: .infinity, maxHeight: 75)
                    }
                }
                .padding()
            }
        }
    }
}
