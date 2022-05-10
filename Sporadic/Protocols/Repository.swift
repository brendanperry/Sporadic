//
//  Repository.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/12/22.
//

import Foundation

protocol Repository {
    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity)
    func fetchChallenges() -> [Challenge]?
    func fetchActivities() -> [Activity]?
    func fetchActiveActivities() -> [Activity]?
    func saveChanges()
    func fetchCurrentChallenge() -> Challenge?
    func getTotalChallengesScheduled() -> Int
    func removeAllPendingChallenges() 
    func popLastScheduledChallenge() -> Date?
    func resolveDuplicateActivities()
}
