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
    
    var challenges = [CompletedChallenge]()
    
    func loadCompletedChallenges(group: UserGroup) async {
        challenges = (try? await CloudKitHelper.shared.getCompletedChallenges(group: group)) ?? []
        
        print(challenges.count)
        
        setData(month: 4, year: 2023, isAllTime: true, separateUsers: false)
    }
    
    private func setData(month: Int, year: Int, isAllTime: Bool, separateUsers: Bool) {
        if isAllTime && !separateUsers {
            DispatchQueue.main.async {
                self.data = self.getAllTimeDataCombined()
            }
        }
    }
    
    private func getAllTimeDataCombined() -> [CompletedChallenge] {
        var preparedData = [CompletedChallenge]()
        
        let dictionary = Dictionary(grouping: challenges, by: { (element: CompletedChallenge) in
            return element.date
        }).sorted(by: { $0.key < $1.key })
        
        var total = 0.0
        
        if let firstDay = dictionary.first?.key {
            if let firstChallenge = dictionary.first?.value.first {
                if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: firstDay) {
                    preparedData.append(CompletedChallenge(activityName: firstChallenge.activityName, amount: 0, challenge: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .none), group: CKRecord.Reference(record: CKRecord(recordType: "Group"), action: .none), unit: firstChallenge.unit, user: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), date: Calendar.current.startOfDay(for: previousDay)))
                }
            }
        }
        
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
