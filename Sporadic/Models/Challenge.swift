//
//  Challenge.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

class Challenge: Identifiable, ObservableObject {
    let id: UUID
    let activityRecord: CKRecord.Reference
    let amount: Double
    let startTime: Date
    let userRecords: [CKRecord.Reference]
    @Published var users: [User]? = nil
    let groupRecord: CKRecord.Reference
    @Published var group: UserGroup? = nil
    let recordId: CKRecord.ID
    @Published var status = ChallengeStatus.unknown
    @Published var usersCompleted = [User]()
    var cachedStatus = ChallengeStatus.unknown
    let activityName: String
    let unit: ActivityUnit
    let currentStreak: Int
    
    init(id: UUID, activityRecord: CKRecord.Reference, amount: Double, startTime: Date, userRecords: [CKRecord.Reference], groupRecord: CKRecord.Reference, recordId: CKRecord.ID, activityName: String, unit: ActivityUnit, currentStreak: Int) {
        self.id = id
        self.activityRecord = activityRecord
        self.amount = amount
        self.startTime = startTime
        self.userRecords = userRecords
        self.groupRecord = groupRecord
        self.recordId = recordId
        self.activityName = activityName
        self.unit = unit
        self.currentStreak = currentStreak
    }
    
    convenience init() {
        self.init(id: UUID(), activityRecord: CKRecord.Reference.init(record: CKRecord(recordType: "Activity"), action: .none), amount: 0, startTime: Date(), userRecords: [CKRecord.Reference.init(record: CKRecord(recordType: "User"), action: .none)], groupRecord: CKRecord.Reference.init(record: CKRecord(recordType: "Group"), action: .none), recordId: CKRecord.ID.init(recordName: "Challenge"), activityName: "Loading activity", unit: .miles, currentStreak: 0)
    }
    
    func getLabel() -> String {
        var unit = unit.rawValue
        if amount == 1 {
            if unit.last == "s" {
                let _ = unit.popLast()
            }
        }
        
        return unit
    }
}

enum ChallengeStatus {
    case userCompleted, groupCompleted, failed, unknown, inProgress
}

extension Challenge {
    convenience init? (from record: CKRecord) {
        guard
            let startTime = record["startTime"] as? Date,
            let users = record["users"] as? [CKRecord.Reference]
        else {
            return nil
        }
        
        let activityReference = record["activity"] as? CKRecord.Reference ?? CKRecord.Reference(record: CKRecord(recordType: "Activity"), action: .none)
        let amount = record["amount"] as? Double
        let group = record["group"] as? CKRecord.Reference ?? CKRecord.Reference(record: CKRecord(recordType: "Group"), action: .none)
        let activityName = record["activityName"] as? String
        let unit = record["unit"] as? String
        let currentStreak = record["currentStreak"] as? Int

        self.init(id: UUID(), activityRecord: activityReference, amount: amount ?? 0, startTime: startTime, userRecords: users, groupRecord: group, recordId: record.recordID, activityName: activityName ?? "", unit: ActivityUnit.init(rawValue: unit ?? "") ?? .miles, currentStreak: currentStreak ?? 0)
    }
    
    func isChallengeTimeUp() -> Bool {
        return Date() > Calendar.current.date(byAdding: .day, value: 1, to: startTime) ?? startTime
    }
    
    func setStatus() {
        Task {
            let status = await getStatus()
            
            DispatchQueue.main.async {
                self.status = status
            }
        }
    }
    
    func getStatus() async -> ChallengeStatus {
        do {
            if let usersCompleted = try await CloudKitHelper.shared.usersWhoHaveCompletedChallenge(challenge: self) {
                let usersCompleted = getUniqueUsers(users: usersCompleted)
                
                await MainActor.run {
                    self.usersCompleted = usersCompleted
                }
            }
        } catch {
            return .unknown
        }
        
        guard let user = CloudKitHelper.shared.getCachedUser() else {
            return .unknown
        }
        
        guard let users = users else {
            return .unknown
        }
        
        if self.usersCompleted.count == users.count {
            cachedStatus = .groupCompleted
            return .groupCompleted
        }
        else if usersCompleted.contains(where: { $0.record.recordID == user.record.recordID }) && !isChallengeTimeUp() {
            cachedStatus = .userCompleted
            return .userCompleted
        }
        else if isChallengeTimeUp() {
            return .failed
        }
        else if cachedStatus != .unknown {
            return cachedStatus
        }
        
        // we save the status in case the user completes the challenge then navigate away
        // and comes back and the challenge hasn't been fully synced to the server yet
        // so we only cache completed statuses
        
        return .inProgress
    }
    
    func getUniqueUsers(users: [User]) -> [User] {
        var recordIds = [CKRecord.ID]()
        var uniqueUsers = [User]()
        
        users.forEach { user in
            if !recordIds.contains(user.record.recordID) {
                recordIds.append(user.record.recordID)
                uniqueUsers.append(user)
            }
        }
        
        return uniqueUsers
    }
}
