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
    
    func createNewUser(usersRecordId: String) async throws -> User? {
        let record = CKRecord(recordType: "User")
        
        record.setValue("Brendan Perry", forKey: "name")
        record.setValue(usersRecordId, forKey: "usersRecordId")
        
        let userRecord = try await database.save(record)
        
        let user = User.init(from: userRecord)
        
        return user
    }
    
    func updateUserName(user: User, completion: @escaping (Error?) -> Void) {
        database.fetch(withRecordID: user.recordId) { [weak self] record, error in
            if let error = error {
                completion(error)
                return
            }
            
            if let record = record {
                record["name"] = user.name
                
                self?.database.save(record) { record, error in
                    if let error = error {
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func updateUserImage(user: User, completion: @escaping (Error?) -> Void) {
        database.fetch(withRecordID: user.recordId) { [weak self] record, error in
            if let error = error {
                completion(error)
                return
            }
            
            if let record = record {
                var asset: CKAsset? = nil
                if let photo = user.photo?.toCKAsset() {
                    asset = photo
                }
                
                record["photo"] = asset
                
                self?.database.save(record) { record, error in
                    if let error = error {
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func getGroupsForUser() async throws -> [UserGroup]? {
        if let user = try await getCurrentUser(forceSync: false) {
            let predicate = NSPredicate(format: "users CONTAINS %@", user.recordId)
            
            let query = CKQuery(recordType: "Group", predicate: predicate)
            
            let result = try await database.records(matching: query)
            let records = try result.matchResults.map { try $0.1.get() }
            
            return records.compactMap { UserGroup.init(from: $0) }
        }
        
        return nil
    }
    
    func getUsersForGroup(group: UserGroup) async throws -> [User]? {
        guard let users = group.users else {
            return nil
        }
        
        let predicate = NSPredicate(format: "recordID IN %@", users)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { User.init(from: $0) }
    }
    
    func getPendingChallengesForGroup(group: UserGroup) async throws -> [Challenge]? {
        guard let challenges = group.challenges else {
            return nil
        }
        
        let predicate = NSPredicate(format: "recordID IN %@ AND startTime > %@", challenges, NSDate())
        
        let query = CKQuery(recordType: "Challenge", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { Challenge.init(from: $0) }
    }
    
    func getActivitiesForGroup(group: UserGroup) async throws -> [Activity]? {
        guard let activities = group.activities else {
            return nil
        }
        
        if activities.count == 0 {
            return []
        }
        
        let predicate = NSPredicate(format: "%@ CONTAINS recordID AND isEnabled = 1", activities)
        
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { Activity.init(from: $0) }
    }
        
    func getChallengesForUser() async throws -> [Challenge]? {
        if let user = try await getCurrentUser(forceSync: false) {
            let reference = CKRecord.Reference(recordID: user.recordId, action: .none)
            
            let predicate = NSPredicate(format: "users CONTAINS %@", reference)

            let query = CKQuery(recordType: "Challenge", predicate: predicate)

            let result = try await database.records(matching: query)
            let records = try result.matchResults.map { try $0.1.get() }

            return records
                    .compactMap({ Challenge.init(from: $0) })
                    .sorted(by: { $0.startTime > $1.startTime })
        }

        return nil
    }
    
    func getGroupFromChallenge(challenge: Challenge, completion: @escaping (UserGroup?) -> Void) {
        database.fetch(withRecordID: challenge.groupRecord.recordID) { groupRecord, error in
            if let error = error {
                print(error)
                completion(nil)
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
                self?.currentGroups?.removeAll(where: { $0.recordId == recordId })
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
    
    // TODO - Allow deleting users
    
    // the problem is that when we set the time it sets it to whatever date the group was created on, we need to set it to the current date
    
    func getTodayAtTimeOf(date: Date) -> Date {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? date
    }
    
    func updateGroup(group: UserGroup, name: String, emoji: String, color: GroupBackgroundColor, completion: @escaping (Error?) -> Void) {
        database.fetch(withRecordID: group.recordId) { [weak self] groupRecord, error in
            if let groupRecord = groupRecord {
                groupRecord.setValue(name, forKey: "name")
                groupRecord.setValue(emoji, forKey: "emoji")
                groupRecord.setValue(group.daysPerWeek, forKey: "daysPerWeek")
                groupRecord.setValue(group.availableDays, forKey: "availableDays")
                groupRecord.setValue(group.displayedDays, forKey: "displayedDays")
                groupRecord.setValue(self?.getTodayAtTimeOf(date: group.deliveryTime), forKey: "deliveryTime")
                groupRecord.setValue(color.rawValue, forKey: "backgroundColor")
                groupRecord.setValue(UserGroup.getDeliveryTimeInt(date: group.deliveryTime), forKey: "deliveryTimeInt")
                
                self?.database.save(groupRecord) { record, error in
                    if let error = error {
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func createGroup(name: String, emoji: String, color: GroupBackgroundColor, days: Int, time: Date, activities: [Activity]) async throws {
        guard let currentUser = try? await getCurrentUser(forceSync: false) else {
            throw NSError(domain: "Current user not found", code: 0, userInfo: [:])
        }
        
        let userReference = CKRecord.Reference(record: CKRecord.init(recordType: "User", recordID: currentUser.recordId), action: .none)
        
        let record = CKRecord(recordType: "Group")
        
        record.setValue(name, forKey: "name")
        record.setValue(emoji, forKey: "emoji")
        record.setValue(days, forKey: "daysPerWeek")
        record.setValue([], forKey: "daysOfTheWeek")
        record.setValue(time, forKey: "deliveryTime")
        record.setValue(color.rawValue, forKey: "backgroundColor")
        record.setValue([userReference], forKey: "users")
        record.setValue([], forKey: "challenges")
        record.setValue([], forKey: "activities")
        record.setValue(UserGroup.getDeliveryTimeInt(date: time), forKey: "deliveryTimeInt")
        
        let groupRecord = try await database.save(record)
        
        var activityReferences = [CKRecord.Reference]()
        for activity in activities {
            addActivityToGroup(groupRecordId: groupRecord.recordID, name: activity.name, unit: activity.unit, minValue: activity.minValue, maxValue: activity.maxValue, templateId: activity.templateId ?? -1) { reference in
                if let reference = reference {
                    activityReferences.append(reference)
                }
            }
        }
        
        let group = UserGroup.init(from: groupRecord)
        
        if let group = group {
            group.activities = activityReferences
            
            currentGroups?.append(group)
        }
    }
    
    func updateActivity(activity: Activity, completion: @escaping (Error?) -> Void) {
        if let recordId = activity.recordId {
            database.fetch(withRecordID: recordId) { [weak self] record, error in
                if let error = error {
                    completion(error)
                }
                else {
                    if let record = record {
                        record.setValue(activity.maxValue, forKey: "maxValue")
                        record.setValue(activity.minValue, forKey: "minValue")
                        
                        self?.database.save(record) { record, error in
                            if let error = error {
                                completion(error)
                            }
                            else {
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addActivityToGroup(groupRecordId: CKRecord.ID, name: String, unit: ActivityUnit, minValue: Double, maxValue: Double, templateId: Int, completion: @escaping (CKRecord.Reference?) -> Void) {
        let record = CKRecord(recordType: "Activity")
        
        record.setValue(templateId, forKey: "templateId")
        record.setValue(1, forKey: "isEnabled")
        record.setValue(name, forKey: "name")
        record.setValue(unit.rawValue, forKey: "unit")
        record.setValue(minValue, forKey: "minValue")
        record.setValue(maxValue, forKey: "maxValue")
        
        database.save(record) { [weak self] record, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            if let record = record {
                let reference = CKRecord.Reference(record: record, action: .none)
                
                self?.database.fetch(withRecordID: groupRecordId) { record, error in
                    if let error = error {
                        print(error)
                        completion(nil)
                        return
                    }
                    
                    if let record = record {
                        if let activities = record["activities"] as? [CKRecord.Reference] {
                            var newActivityList = activities
                            newActivityList.append(reference)
                            
                            record.setValue(newActivityList, forKey: "activities")
                            
                            self?.database.save(record) { record, error in
                                if let error = error {
                                    print(error)
                                    completion(nil)
                                }
                                else {
                                    completion(reference)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

