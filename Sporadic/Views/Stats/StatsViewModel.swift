//
//  StatsViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 4/19/23.
//

import Foundation
import CloudKit

enum SporadicGraphType: String {
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"
}

class StatsViewModel: ObservableObject {
    @Published var data = [CompletedChallenge]()
    @Published var total = 0.0
    @Published var selectedMonth = Calendar.current.dateComponents([.month], from: Date()).month ?? 1
    @Published var selectedYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 2023
    @Published var graphType = SporadicGraphType.month
    @Published var selectedActivity = Activity(record: CKRecord(recordType: "Activity"), maxValue: 0, minValue: 0, name: "", unit: ActivityUnit.general)
    @Published var selectedGroup: UserGroup? = nil
    @Published var showUsers = false
    
    var challenges = [CompletedChallenge]()
    
    func loadCompletedChallenges(forceSync: Bool) async {
        guard let selectedGroup else {
            return
        }
        
        challenges = (try? await CloudKitHelper.shared.getCompletedChallenges(group: selectedGroup, forceSync: forceSync)) ?? []
        
        setData(month: 4, year: 2023, isAllTime: true)
    }
    
    private func setData(month: Int, year: Int, isAllTime: Bool) {
        if isAllTime && !showUsers {
            DispatchQueue.main.async {
                self.data = self.getAllTimeDataCombined()
            }
        }
        else if isAllTime && showUsers {
            DispatchQueue.main.async {
                self.data = self.getAllTimeDataCombined()
            }
        }
    }
    
    private func getAllTimeDataCombined() -> [CompletedChallenge] {
        var preparedData = [CompletedChallenge]()
        
        let challenges = challenges.filter({ $0.activityName == selectedActivity.name })
        
        let dictionary = Dictionary(grouping: challenges, by: { (element: CompletedChallenge) in
            return element.date
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
