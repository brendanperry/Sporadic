//
//  CloudKitHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

class CloudKitHelper: Repository {
    let container: CKContainer
    let database: CKDatabase

    static let shared = CloudKitHelper()
    let oneSignalHelper = OneSignalHelper()
    
    private var cachedUser: User?
    public var currentUser: User? {
        get async throws {
            if let cachedUser = cachedUser {
                return cachedUser
            }
            
            let userId = (try await container.userRecordID()).recordName
                        
            let predicate = NSPredicate(format: "usersRecordId = %@", userId)
            
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            let result = try await database.records(matching: query)
            
            let records = try result.matchResults.map { try $0.1.get() }
            
            if let record = records.first {
                cachedUser = User.init(from: record)
                
                return cachedUser
            }
            
            return nil
        }
    }

    private init() {
        container = CKContainer(identifier: "iCloud.Sporadic")
        database = container.publicCloudDatabase
    }
    
    func getGroupsForUser() async throws -> [UserGroup]? {
        if let user = try await currentUser {
            let predicate = NSPredicate(format: "usersInGroup CONTAINS %@", user.usersRecordId)
            
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
    
    func getActivitiesForGroup(group: UserGroup) async throws -> [Activity]? {
        guard let activities = group.activities else {
            return nil
        }
        
        let predicate = NSPredicate(format: "recordID IN %@", activities)
        
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { Activity.init(from: $0) }
    }
        
    // need the record id of the current user to get the reference to work?
    func getChallengesForUser() async throws -> [Challenge]? {
//        if let user = try await currentUser {
//            let predicate = NSPredicate(format: "users CONTAINS %@", user.recordId)
//
//            let query = CKQuery(recordType: "Challenge", predicate: predicate)
//
//            let result = try await database.records(matching: query)
//            let records = try result.matchResults.map { try $0.1.get() }
//
//            return records.compactMap { Challenge.init(from: $0) }
//        }
//
        return nil
    }
    
    func createGroup(name: String, emoji: String, color: GroupBackgroundColor, activities: [Activity]) async throws {
        // normal record id or usersrecordid
        guard let userRecordId = try? await currentUser?.usersRecordId else {
            return
        }
        
        let record = CKRecord(recordType: "Group")
        
        record.setValue(name, forKey: "name")
        record.setValue(emoji, forKey: "emoji")
        record.setValue(color.rawValue, forKey: "backgroundColor")
        record.setValue([userRecordId], forKey: "users")
        
        let group = try await database.save(record)
        
        for activity in activities {
            addActivityToGroup(groupRecordId: group.recordID, name: activity.name, unit: activity.unit, minValue: activity.minValue, maxValue: activity.maxValue) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func addActivityToGroup(groupRecordId: CKRecord.ID, name: String, unit: String, minValue: Double, maxValue: Double, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "Activity")
        
        record.setValue(name, forKey: "name")
        record.setValue(unit, forKey: "unit")
        record.setValue(minValue, forKey: "minValue")
        record.setValue(maxValue, forKey: "maxValue")
        
        database.save(record) { [weak self] record, error in
            if let error = error {
                print("error")
                completion(error)
                return
            }
            
            if let record = record {
                let reference = CKRecord.Reference(record: record, action: .none)
                
                self?.database.fetch(withRecordID: groupRecordId) { record, error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    if let record = record {
                        if let activities = record["activities"] as? [CKRecord.Reference] {
                            var newActivityList = activities
                            newActivityList.append(reference)
                            
                            record.setValue(newActivityList, forKey: "activities")
                            
                            self?.database.save(record) { record, error in
                                if let error = error {
                                    completion(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

