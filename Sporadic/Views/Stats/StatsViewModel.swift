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
    
    var challenges = [CompletedChallenge]()
    
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
    
    func loadCompletedChallenges(forceSync: Bool) async {
        guard let selectedGroup else {
            return
        }
        
        challenges = (try? await CloudKitHelper.shared.getCompletedChallenges(group: selectedGroup, forceSync: forceSync)) ?? []
        
        setData(month: 4, year: 2023, isAllTime: true)
    }
    
    private func setData(month: Int, year: Int, isAllTime: Bool) {
        DispatchQueue.main.async {
            self.data = self.getAllTimeDataCombined()
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
            
            let days = Calendar.current.dateComponents([.day], from: self.challenges.first?.date ?? Date(), to: self.challenges.last?.date ?? Date()).day ?? 1
            
            self.yourAvg = self.yourTotal / Double(days)
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
