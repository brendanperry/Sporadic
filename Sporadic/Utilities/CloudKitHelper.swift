//
//  CloudKitHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit
import OneSignal


class CloudKitHelper {
    let container: CKContainer
    let database: CKDatabase

    static let shared = CloudKitHelper()
    
    private var currentGroups: [UserGroup]?
    
    private init() {
        container = CKContainer(identifier: "iCloud.Sporadic")
        database = container.publicCloudDatabase
    }
    
    private var cachedUser: User?
    func getCurrentUser(forceSync: Bool) async throws -> User? {
        if !forceSync {
            if let cachedUser = cachedUser {
                return cachedUser
            }
        }
        
        let userId = (try await container.userRecordID()).recordName
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            OneSignal.setExternalUserId(userId)
        })
        
        let predicate = NSPredicate(format: "usersRecordId = %@", userId)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        let result = try await database.records(matching: query)
        
        let records = try result.matchResults.map { try $0.1.get() }
        
        if let record = records.first {
            cachedUser = User.init(from: record)
           
            return cachedUser
        }
        else {
            let user = try await createNewUser(usersRecordId: userId)
            
            if let user = user {
                cachedUser = user
                
                return cachedUser
            }
        }
        
        return nil
    }
    
    func hasUser() -> Bool {
        return cachedUser != nil
    }
    
    func createNewUser(usersRecordId: String) async throws -> User? {
        let record = CKRecord(recordType: "User")
        
        record.setValue("Brendan Perry", forKey: "name")
        record.setValue(usersRecordId, forKey: "usersRecordId")
        
        let userRecord = try await database.save(record)
        
        let user = User.init(from: userRecord)
        
        return user
    }
    
    func updateUserName(user: User, completion: @escaping (Error?) -> Void) {
        let record = user.record
        record["name"] = user.name
        
        database.save(record) { record, error in
            if let error = error {
                completion(error)
            }
            else {
                if let record = record {
                    user.record = record
                }
                
                completion(nil)
            }
        }
    }
    
    func updateUserImage(user: User, completion: @escaping (Error?) -> Void) {
        let record = user.record
        
        if let photo = user.photo?.toCKAsset() {
            record["photo"] = photo
            
            database.save(record) { record, error in
                if let error = error {
                    completion(error)
                }
                else {
                    if let record = record {
                        user.record = record
                    }

                    completion(nil)
                }
            }
        }
    }
    
    func getGroup(byId id: CKRecord.ID, completion: @escaping (Result<UserGroup, CustomError>) -> Void) {
        database.fetch(withRecordID: id) { [weak self] record, error in
            if let _ = error {
                completion(.failure(.connectionError))
                return
            }
            
            if let groupRecord = record {
                if let group = UserGroup.init(from: groupRecord) {
                    if let user = self?.cachedUser {
                        if user.groups.contains(where: { $0.recordID == group.record.recordID }) {
                            completion(.failure(.alreadyInGroup))
                        }
                        else {
                            completion(.success(group))
                        }
                    }
                }
            }
            else {
                completion(.failure(.groupNotFound))
            }
        }
    }
    
    func getGroupsForUser(currentGroups: [UserGroup], completion: @escaping ([UserGroup]?) -> Void) {
        guard let user = cachedUser else {
            completion(nil)
            return
        }
        
        let currentGroupIds = currentGroups.map { $0.record.recordID }
        let groupIds = user.groups.map { $0.recordID }
        
        let predicate = NSPredicate(format: "recordID in %@", groupIds)
        let query = CKQuery(recordType: "Group", predicate: predicate)
        
        database.fetch(withQuery: query) { [weak self] result in
            switch result {
            case .success(let (matches,_)):
                var groupsToAdd = [UserGroup]()
                
                for match in matches {
                    switch match.1 {
                    case .success(let record):
                        if currentGroupIds.contains(where: { $0 == record.recordID }) {
                           continue
                        }
                        
                        if let group = UserGroup.init(from: record) {
                            groupsToAdd.append(group)
                        }
                    case .failure(_):
                        completion(nil)
                    }
                }
                
                var groups = currentGroups
                groups.append(contentsOf: groupsToAdd)
                
                self?.currentGroups = groups
                
                completion(groups)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func getGroupsForUser() async throws -> [UserGroup]? {
        if let user = try await getCurrentUser(forceSync: false) {
            let predicate = NSPredicate(format: "users CONTAINS %@", user.record)
            
            let query = CKQuery(recordType: "Group", predicate: predicate)
            
            let result = try await database.records(matching: query)
            let records = try result.matchResults.map { try $0.1.get() }
            
            return records.compactMap { UserGroup.init(from: $0) }
        }
        
        return nil
    }
    
    func getUsersForGroup(group: UserGroup) async throws -> [User]? {
        let predicate = NSPredicate(format: "groups CONTAINS %@", group.record)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { User.init(from: $0) }
    }
    
    func getActivitiesForGroup(group: UserGroup) async throws -> [Activity]? {
        let predicate = NSPredicate(format: "group == %@", group.record)
        
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { Activity.init(from: $0) }
    }
        
    func getChallengesForUser(currentChallenges: [Challenge]) async throws -> [Challenge]? {
        if let user = try await getCurrentUser(forceSync: false) {
            let predicate = NSPredicate(format: "users CONTAINS %@", user.record)

            let query = CKQuery(recordType: "Challenge", predicate: predicate)

            let result = try await database.records(matching: query)
            let records = try result.matchResults.map { try $0.1.get() }
            
            let newChallenges = records
                .compactMap({ Challenge.init(from: $0) })
                .sorted(by: { $0.startTime > $1.startTime })
            
            if currentChallenges.elementsEqual(newChallenges, by: { $0.recordId == $1.recordId }) {
                return currentChallenges
            }
            else {
                var challenges = currentChallenges
                let currentIds = currentChallenges.map { $0.recordId }
                
                for challenge in newChallenges {
                    if !currentIds.contains(challenge.recordId) {
                        challenges.append(challenge)
                    }
                }
                
                return challenges
            }
        }

        return nil
    }
    
    func getGroupFromChallenge(challenge: Challenge, completion: @escaping (UserGroup?) -> Void) {
        database.fetch(withRecordID: challenge.groupRecord.recordID) { groupRecord, error in
            if let error = error {
                if error.localizedDescription.contains("not found") {
                    let group = UserGroup(activities: nil, challenges: nil, displayedDays: [], daysPerWeek: 0, deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "Group Deleted", users: nil, record: CKRecord(recordType: "Group"))
                    
                    completion(group)
                }
                else {
                    completion(nil)
                }
            }
            else {
                if let record = groupRecord {
                    if let group = UserGroup.init(from: record) {
                        completion(group)
                    }
                    else {
                        completion(nil)
                    }
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    func getUsersFromChallenge(challenge: Challenge, completion: @escaping ([User]) -> Void) {
        database.fetch(withRecordIDs: challenge.userRecords.map { $0.recordID }) { result in
            switch result {
            case .failure(let error):
                print(error)
                completion([])
            case .success(let responseDict):
                var users = [User]()
                
                for response in responseDict.values {
                    switch response {
                    case .failure(let error):
                        print(error)
                        completion([])
                        return
                    case .success(let record):
                        let user = User.init(from: record)
                        
                        if let user = user {
                            users.append(user)
                        }
                    }
                }
                
                completion(users)
            }
        }
    }
    
    func getActivityFromChallenge(challenge: Challenge, completion: @escaping (Activity?) -> Void) {
        database.fetch(withRecordID: challenge.activityRecord.recordID) { activityRecord, error in
            if let error = error {
                print(error)
                completion(nil)
            }
            else {
                if let record = activityRecord {
                    if let activity = Activity.init(from: record) {
                        completion(activity)
                    }
                    else {
                        completion(nil)
                    }
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    func deleteGroup(recordId: CKRecord.ID, completion: @escaping (Error?) -> Void) {
        deleteRecord(recordId: recordId) { [weak self] error in
            if let error = error {
                completion(error)
            }
            else {
                self?.currentGroups?.removeAll(where: { $0.record.recordID == recordId })
                completion(nil)
            }
        }
    }
    
    func deleteRecord(recordId: CKRecord.ID, completion: @escaping (Error?) -> Void) {
        database.delete(withRecordID: recordId) { record, error in
            if let error = error {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
        
    func getTodayAtTimeOf(date: Date) -> Date {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? date
    }
    
    func updateGroup(group: UserGroup, name: String, emoji: String, color: GroupBackgroundColor, completion: @escaping (Error?) -> Void) {
        let record = group.record
        
        record.setValue(name, forKey: "name")
        record.setValue(emoji, forKey: "emoji")
        record.setValue(group.daysPerWeek, forKey: "daysPerWeek")
        record.setValue(group.availableDays, forKey: "availableDays")
        record.setValue(group.displayedDays, forKey: "displayedDays")
        record.setValue(getTodayAtTimeOf(date: group.deliveryTime), forKey: "deliveryTime")
        record.setValue(color.rawValue, forKey: "backgroundColor")
        record.setValue(UserGroup.getDeliveryTimeInt(date: group.deliveryTime), forKey: "deliveryTimeInt")
        
        database.save(record) { record, error in
            if let error = error {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func createGroup(name: String, emoji: String, color: GroupBackgroundColor, days: Int, time: Date, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "Group")
        
        record.setValue(name, forKey: "name")
        record.setValue(emoji, forKey: "emoji")
        record.setValue(days, forKey: "daysPerWeek")
        record.setValue([], forKey: "daysOfTheWeek")
        record.setValue(time, forKey: "deliveryTime")
        record.setValue(color.rawValue, forKey: "backgroundColor")
        record.setValue(UserGroup.getDeliveryTimeInt(date: time), forKey: "deliveryTimeInt")
        
        database.save(record) { [weak self] record, error in
            if let error = error {
                completion(error)
                return
            }
            
            if let record = record {
                if let group = UserGroup.init(from: record) {
                    self?.addUserToGroup(group: group) { error in
                        if let error = error {
                            completion(error)
                            return
                        }
                        
                        self?.currentGroups?.append(group)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func updateActivity(activity: Activity, completion: @escaping (Error?) -> Void) {
        if let recordId = activity.recordId {
            let record = CKRecord(recordType: "Activity", recordID: recordId)
            record.setValue(activity.maxValue, forKey: "maxValue")
            record.setValue(activity.minValue, forKey: "minValue")
            
            database.save(record) { record, error in
                if let error = error {
                    completion(error)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    func addUserToGroup(group: UserGroup, completion: @escaping (Error?) -> Void) {
        guard let user = cachedUser else {
            completion(NSError(domain: "User not found", code: 0))
            return
        }
        
        var groups = user.groups
        let newGroupReference = CKRecord.Reference(recordID: group.record.recordID, action: .none)
        groups.append(newGroupReference)
        
        let record = user.record
        
        record.setValue(groups, forKey: "groups")
        
        database.save(record) { record, error in
            if let error = error {
                print(error)
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
    func createActivity(groupRecordId: CKRecord.ID, name: String, unit: ActivityUnit, minValue: Double, maxValue: Double, templateId: Int, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "Activity")
        
        let groupReference = CKRecord.Reference(recordID: groupRecordId, action: .none)
        
        record.setValue(templateId, forKey: "templateId")
        record.setValue(1, forKey: "isEnabled")
        record.setValue(name, forKey: "name")
        record.setValue(unit.rawValue, forKey: "unit")
        record.setValue(minValue, forKey: "minValue")
        record.setValue(maxValue, forKey: "maxValue")
        record.setValue(groupReference, forKey: "group")
        
        database.save(record) { record, error in
            if let error = error {
                print(error)
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
}
