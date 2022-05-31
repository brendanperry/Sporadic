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
    let userId = UserDefaults.standard.string(forKey: UserPrefs.userId.rawValue) ?? ""

    static let shared = CloudKitHelper()
    let oneSignalHelper = OneSignalHelper()

    private init() {
        container = CKContainer.default()
        
        database = container.publicCloudDatabase
    }
    
    func getGroupsForUser() async throws -> [UserGroup]? {
        if let user = try await getUserRecord() {
            let predicate = NSPredicate(format: "users CONTAINS[c] %@", user.recordId)
            
            let query = CKQuery(recordType: "Group", predicate: predicate)
            
            let result = try await database.records(matching: query)
            let records = try result.matchResults.map { try $0.1.get() }
            
            return records.compactMap { UserGroup.init(from: $0) }
        }
        
        return nil
    }
    
    func getActivitiesForGroup(group: UserGroup) async throws -> [Activity]? {
        let predicate = NSPredicate(format: "recordID IN %@", group.activities)
        
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = try result.matchResults.map { try $0.1.get() }
        
        return records.compactMap { Activity.init(from: $0) }
    }
    
    // need the record id of the current user to get the reference to work?
    func getChallengesForUser() async throws -> [Challenge]? {
        if let user = try await getUserRecord() {
            let predicate = NSPredicate(format: "users CONTAINS %@", user.recordId)
            
            let query = CKQuery(recordType: "Challenge", predicate: predicate)
            
            let result = try await database.records(matching: query)
            let records = try result.matchResults.map { try $0.1.get() }
            
            return records.compactMap { Challenge.init(from: $0) }
        }
        
        return nil
    }
    
    // cache this later!
    func getUserRecord() async throws -> User? {
        let predicate = NSPredicate(format: "id = %@", userId)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        let result = try await database.records(matching: query)
        
        let records = try result.matchResults.map { try $0.1.get() }
        
        if let record = records.first {
            return User.init(from: record)
        }
        
        return nil
    }
}

