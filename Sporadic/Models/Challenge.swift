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
    var activity: Activity? = nil
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
    
    init(id: UUID, activityRecord: CKRecord.Reference, amount: Double, startTime: Date, userRecords: [CKRecord.Reference], groupRecord: CKRecord.Reference, recordId: CKRecord.ID) {
        self.id = id
        self.activityRecord = activityRecord
        self.amount = amount
        self.startTime = startTime
        self.userRecords = userRecords
        self.groupRecord = groupRecord
        self.recordId = recordId
    }
}

enum ChallengeStatus {
    case userCompleted, groupCompleted, failed, unknown, inProgress
}

extension Challenge {
    convenience init? (from record: CKRecord) {
        guard
            let activityReference = record["activity"] as? CKRecord.Reference,
            let amount = record["amount"] as? Double,
            let startTime = record["startTime"] as? Date,
            let users = record["users"] as? [CKRecord.Reference],
            let group = record["group"] as? CKRecord.Reference
        else {
            return nil
        }
        
        self.init(id: UUID(), activityRecord: activityReference, amount: amount, startTime: startTime, userRecords: users, groupRecord: group, recordId: record.recordID)
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
        // we save the status in case the user completes the challenge then navigate away
        // and comes back and the challenge hasn't been fully synced to the server yet
        // so we only cache completed statuses
        if cachedStatus != .unknown {
            return cachedStatus
        }
        
        guard let user = CloudKitHelper.shared.getCachedUser() else {
            return .unknown
        }
        
        guard let users = users else {
            return .unknown
        }
        
        do {
            if let usersCompleted = try await CloudKitHelper.shared.usersWhoHaveCompletedChallenge(challenge: self) {
                let usersCompleted = getUniqueUsers(users: usersCompleted)
                
                DispatchQueue.main.async {
                    self.usersCompleted = usersCompleted
                }
                
                if usersCompleted.count == users.count {
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
                else {
                    return .inProgress
                }
            }
        } catch {
            return .unknown
        }
        
        return .unknown
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
