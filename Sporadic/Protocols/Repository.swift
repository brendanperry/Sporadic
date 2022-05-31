//
//  Repository.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/12/22.
//

import Foundation

protocol Repository {
//    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity) -> Challenge
//    func fetchChallenges() -> [Challenge]?
//    func fetchActivities() -> [Activity]?
//    func fetchActiveActivities() -> [Activity]?
//    func saveChanges()
//    func fetchCurrentChallenge() -> Challenge?
//    func getTotalChallengesScheduled() -> Int
//    func removeAllPendingChallenges() -> [String]
//    func getDayAfterLastChallenge() -> Date?
//    func resolveDuplicateActivities()
//    func setChallengeNotification(challenge: Challenge, notificationId: String)
    
    func getGroupsForUser() async throws -> [UserGroup]?
    func getActivitiesForGroup(group: UserGroup) async throws -> [Activity]?
    func getChallengesForUser() async throws -> [Challenge]?
    func getUserRecord() async throws -> User?
}
