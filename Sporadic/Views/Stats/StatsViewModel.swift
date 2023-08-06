//
//  StatsViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 4/19/23.
//

import Foundation
import CloudKit


class StatsViewModel: ObservableObject {
    @Published var data = [CompletedChallenge]()
    @Published var total = 0.0
    @Published var yourTotal = 0.0
    @Published var yourAvg = 0.0
    @Published var selectedMonth = Calendar.current.dateComponents([.month], from: Date()).month ?? 1
    @Published var selectedYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 2023
    @Published var selectedActivity = Activity(record: CKRecord(recordType: "Activity"), maxValue: 0, minValue: 0, name: "", templateId: -1, unit: ActivityUnit.miles)
    @Published var selectedGroup: UserGroup? = nil
    @Published var showUsers = false
    @Published var isLoading = false
    @Published var areGroupsLoaded = false
    @Published var streak = -1
    
    var challenges = [CompletedChallenge]()
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        return formatter
    }()
    
    func waitForGroupsToFinishLoading(homeViewModel: HomeViewModel) {
        if areGroupsDoneLoading(homeViewModel: homeViewModel) {
            areGroupsLoaded = true
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if self?.areGroupsDoneLoading(homeViewModel: homeViewModel) ?? false {
                self?.areGroupsLoaded = true
                timer.invalidate()
            }
        }
    }
    
    func areGroupsDoneLoading(homeViewModel: HomeViewModel) -> Bool {
        return (homeViewModel.areGroupsLoading == false && homeViewModel.groups.allSatisfy({ !$0.areActivitiesLoading && !$0.areUsersLoading }))
    }
    
    func moveBackOneMonth() {
        if selectedMonth > 1 {
            selectedMonth -= 1
        }
        else {
            selectedMonth = 12
        }
    }
    
    func moveForwardOneMonth() {
        if selectedMonth < 12 {
            selectedMonth += 1
        }
        else {
            selectedMonth = 1
        }
    }
    
    func loadCompletedChallenges(forceSync: Bool) {
        guard let selectedGroup else {
            return
        }
        
        Task {
            DispatchQueue.main.async {
                self.streak = -1
                Task {
                    self.streak = await CloudKitHelper.shared.getStreakForGroup(group: selectedGroup)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        CloudKitHelper.shared.fetchCompletedChallenges(group: selectedGroup, forceSync: forceSync) { [weak self] result in
            switch result {
            case .success(let completedChallenges):
                self?.challenges = completedChallenges
                self?.setData(month: 4, year: 2023, isAllTime: true)
            case .failure(let error):
                print(error)
            }
        }
//        challenges = (try? await CloudKitHelper.shared.getCompletedChallenges(group: selectedGroup, forceSync: forceSync)) ?? []
        
    }
    
    private func setData(month: Int, year: Int, isAllTime: Bool) {
        DispatchQueue.main.async {
            self.data = self.getAllTimeDataCombined()
            self.isLoading = false
        }
    }
    
    private func getAllTimeDataCombined() -> [CompletedChallenge] {
        var preparedData = [CompletedChallenge]()
        
        challenges = challenges.filter({ $0.activityName == selectedActivity.name }).sorted(by: { $0.date < $1.date })
        
        guard let user = CloudKitHelper.shared.getCachedUser() else {
            return []
        }
        
        DispatchQueue.main.async {
            self.yourTotal = self.challenges.filter({ $0.user.recordID == user.record.recordID }).reduce(0, { $0 + $1.amount })
            
            let days = Calendar.current.dateComponents([.day], from: self.challenges.first?.date ?? Date(), to: Date()).day ?? 1
            
            self.yourAvg = self.yourTotal / Double(days + 1)
        }
        
        let dictionary = Dictionary(grouping: challenges, by: { (element: CompletedChallenge) in
            return Calendar.current.startOfDay(for: element.date)
        }).sorted(by: { $0.key < $1.key })
        
        var total = 0.0
        
        for entry in dictionary {
            if var combinedChallenge = entry.value.first {
                let totalAmount = entry.value.reduce(0, { $0 + $1.amount })
                combinedChallenge.amount = totalAmount + total
                
                preparedData.append(combinedChallenge)
                
                total += totalAmount
            }
        }
        
        DispatchQueue.main.async {
            self.total = total
        }
        
        return preparedData
    }
}
