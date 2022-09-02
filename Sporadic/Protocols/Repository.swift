//
//  Repository.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/12/22.
//

import Foundation
import CloudKit

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
    
    func getGroupsForUser(forceSync: Bool) async throws -> [UserGroup]?
    func getActivitiesForGroup(group: UserGroup) async throws -> [Activity]?
    func getChallengesForUser(forceSync: Bool) async throws -> [Challenge]?
    func getUsersForGroup(group: UserGroup) async throws -> [User]?
    func addActivityToGroup(groupRecordId: CKRecord.ID, name: String, unit: ActivityUnit, minValue: Double, maxValue: Double, templateId: Int, completion: @escaping (CKRecord.Reference?) -> Void)
    func createGroup(name: String, emoji: String, color: GroupBackgroundColor, days: Int, time: Date, activities: [Activity]) async throws
}
