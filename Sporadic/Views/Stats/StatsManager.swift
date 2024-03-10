//
//  StatsManager.swift
//  Sporadic
//
//  Created by brendan on 12/17/23.
//

import Foundation

struct StatsManager {
    func getPersonalStatsForOneExercise(challenges: [CompletedChallenge], user: User) -> (Double, Double) {
        var total = 0.0
        var average = 0.0
        
        total = challenges.filter({ $0.user.recordID == user.record.recordID }).reduce(0, { $0 + $1.amount })
        
        let days = Calendar.current.dateComponents([.day], from: challenges.first?.date ?? Date(), to: Date()).day ?? 1
        
        average = total / Double(days + 1)
        
        return (total, average)
    }
    
    func getGroupStatsForOneExercise(challenges: [CompletedChallenge]) -> (Double, [CompletedChallenge]) {
        var preparedData = [CompletedChallenge]()
        
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
        
        return (total, preparedData)
    }
}
