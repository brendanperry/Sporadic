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
    @FocusState var isPickerFocused: Bool
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.areGroupsLoaded {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        TextHelper.text(key: "Analytics", alignment: .leading, type: .h1)
                            .padding(.top, 50)
                            .padding(.bottom)
                            .onTapGesture {
                                isPickerFocused = true
                            }
                        
                        if !homeViewModel.areGroupsLoading && !homeViewModel.groups.isEmpty {
                            GroupPicker(selectedGroup: $viewModel.selectedGroup, homeViewModel: homeViewModel)
                                .onChange(of: viewModel.selectedGroup) { _ in
                                    viewModel.selectedActivity = viewModel.selectedGroup?.activities.first ?? viewModel.selectedActivity
                                }
                                .onChange(of: viewModel.selectedGroup?.activities) { newVal in
                                    viewModel.selectedActivity = viewModel.selectedGroup?.activities.first ?? viewModel.selectedActivity
                                }
                            
                            ActivityPicker(selectedActivity: $viewModel.selectedActivity, activities: homeViewModel.groups.first(where: { $0.record.recordID == viewModel.selectedGroup?.record.recordID })?.activities ?? [])
                                .onChange(of: viewModel.selectedActivity) { _ in
                                    viewModel.loadCompletedChallenges(forceSync: false)
                                }
                            
                            GraphSection(viewModel: viewModel)
                            
                            Streak(streak: viewModel.streak)
                            
                            if viewModel.data.count > 1 {
                                HStack(spacing: 15) {
                                    YourTotal(total: viewModel.yourTotal, unit: viewModel.selectedActivity.unit.toString(), formatter: viewModel.formatter)
                                    
                                    YourAvg(average: viewModel.yourAvg, unit: viewModel.selectedActivity.unit.toString(), formatter: viewModel.formatter)
                                }
                            }
                        }
                        else if !homeViewModel.areGroupsLoading && homeViewModel.groups.isEmpty {
                            TextHelper.text(key: "Get started by creating a group.", alignment: .center, type: .body)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                    .preferredColorScheme(ColorSchemeHelper().getColorSceme())
                    .padding(.top)
                }
                .padding(.top, 1)
                .refreshable {
                    viewModel.loadCompletedChallenges(forceSync: true)
                }
            }
            else {
                LoadingIndicator()
            }
            
            NavigationBar(viewRouter: viewRouter)
        }
        .onAppear {
            viewModel.waitForGroupsToFinishLoading(homeViewModel: homeViewModel)
        }
    }
    
    struct YourTotal: View {
        let total: Double
        let unit: String
        let formatter: NumberFormatter
        
        var body: some View {
            VStack(alignment: .leading) {
                Image("Your Total")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .padding()
                
                TextHelper.text(key: "Your total", alignment: .leading, type: .body)
                    .padding(.horizontal)
                
                TextHelper.text(key: "\(formatter.string(from: total as NSNumber) ?? "") \(unit)", alignment: .leading, type: .h3)
                    .padding([.horizontal, .bottom])
            }
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
        }
    }
    
    struct YourAvg: View {
        let average: Double
        let unit: String
        let formatter: NumberFormatter
        
        var body: some View {
            VStack(alignment: .leading) {
                Image("Your Avg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .padding()
                
                TextHelper.text(key: "Your daily avg.", alignment: .leading, type: .body)
                    .padding(.horizontal)
                
                TextHelper.text(key: "\(formatter.string(from: average as NSNumber) ?? "") \(unit)", alignment: .leading, type: .h3)
                    .padding([.horizontal, .bottom])
            }
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
        }
    }
    
    struct GraphSection: View {
        @ObservedObject var viewModel: StatsViewModel
        
        var body: some View {
            VStack (alignment: .leading) {
                if viewModel.isLoading {
                    VStack {
                        TextHelper.text(key: "Loading group data...", alignment: .center, type: .body)
                        
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                        
                    }
                    .padding()
                }
                else if viewModel.data.count < 2 {
                    TextHelper.text(key: "Not enough data to display.", alignment: .center, type: .body)
                        .padding()
                }
                else {
                    Image("Group Total")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding()
                    
                    TextHelper.text(key: "Group total", alignment: .leading, type: .body)
                        .padding(.horizontal)
                    
                    TextHelper.text(key: "\(viewModel.formatter.string(from: viewModel.total as NSNumber) ?? "") \(viewModel.selectedActivity.unit.toString())", alignment: .leading, type: .h3)
                        .padding([.horizontal, .bottom])
                    
                    GroupChart(data: viewModel.data, groupColor: GroupBackgroundColor(rawValue: viewModel.selectedGroup?.backgroundColor ?? 0)?.getColor() ?? Color.blue)
                }
            }
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
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
                AxisMarks(preset: .aligned) {
                    AxisValueLabel()
                        .font(Font.custom("Lexend-SemiBold", size: 11))
                        .foregroundStyle(Color("Gray200"))
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
                    if selectedGroup != nil {
                        Text(selectedGroup?.emoji ?? "")
                            .font(.title3)
                            .padding(5)
                            .background(Circle().foregroundColor(GroupBackgroundColor.init(rawValue: selectedGroup?.backgroundColor ?? 0)?.getColor()))
                    }
                    
                    TextHelper.text(key: selectedGroup?.name ?? "Select Group", alignment: .leading, type: .h3)
                        .truncationMode(.tail)
                        .lineLimit(1)
                    
                    Image("Expand")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: homeViewModel.groups) { _ in
                    if selectedGroup == nil {
                        selectedGroup = homeViewModel.groups.first
                    }
                }
                .onAppear {
                    if !homeViewModel.groups.isEmpty && selectedGroup == nil {
                        selectedGroup = homeViewModel.groups.first
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color("Panel"))
                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)

                HStack(spacing: 0) {
                    Menu {
                        ForEach(homeViewModel.groups) { group in
                            Button(group.name) {
                                selectedGroup = group
                            }
                        }
                    } label: {
                        TextHelper.text(key: "PlaceHolder", alignment: .leading, type: .h3, color: .clear)
                            .padding()
                    }
                }
            }
        }
    }
    
    struct ActivityPicker: View {
        @Binding var selectedActivity: Activity
        let activities: [Activity]
        
        var body: some View {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        if !activities.isEmpty {
                            Image(selectedActivity.template != nil ? selectedActivity.name : "Custom Activity Icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .padding(5)
                                .background(Circle().foregroundColor(selectedActivity.template?.color ?? Color("CustomExercise")))
                            
                            TextHelper.text(key: selectedActivity.name, alignment: .leading, type: .h3)
                                .truncationMode(.tail)
                                .lineLimit(1)
                            
                            Image("Expand")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color("Panel"))
                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)

                HStack(spacing: 0) {
                    Menu {
                        ForEach(activities) { activity in
                            Button(activity.name) {
                                selectedActivity = activity
                            }
                        }
                    } label: {
                        TextHelper.text(key: "PlaceHolder", alignment: .leading, type: .h3, color: .clear)
                            .padding()
                    }
                }
            }
        }
    }
    
    struct Streak: View {
        let streak: Int
        
        var body: some View {
            HStack{
                Spacer()
                
                Image("Streaks Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                
                Text("Completion Streak: ")
                    .font(Font.custom("Lexend-Regular", size: 14, relativeTo: .title3))
                    .foregroundColor(Color("StreaksText"))
                
                Text(streak == -1 ? "-" : "\(streak)")
                    .font(Font.custom("Lexend-SemiBold", size: 19, relativeTo: .title2))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                    .foregroundColor(Color("Streaks"))
                    .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
            )
        }
    }
}
