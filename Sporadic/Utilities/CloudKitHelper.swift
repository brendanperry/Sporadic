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
        
        let predicate = NSPredicate(format: "usersRecordId = %@", userId)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        let result = try await database.records(matching: query)
        
        let records = try result.matchResults.map { try $0.1.get() }
        
        if let record = records.first {
            cachedUser = User.init(from: record)
            
            if let userId = cachedUser?.usersRecordId {
                OneSignal.setExternalUserId(userId)
            }
            
            if cachedUser?.notificationId != OneSignal.getDeviceState().userId {
                if let user = cachedUser {
                    CloudKitHelper.shared.updateNotificationId(user: user) { error in
                        if let error {
                            print(error)
                        }
                    }
                }
            }
           
            return cachedUser
        }
        else {
            // The user object may not be indexed server side yet, let's not create a new user if we already have one on device to avoid duplicates
            if cachedUser != nil { return cachedUser }
            
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
    
    func getCachedUser() -> User? {
        return cachedUser
    }
    
    func createNewUser(usersRecordId: String) async throws -> User? {
        let record = CKRecord(recordType: "User")
        
        record.setValue("Challenger", forKey: "name")
        record.setValue(usersRecordId, forKey: "usersRecordId")
        record.setValue(OneSignal.getDeviceState().userId ?? "", forKey: "notificationId")
        
        let userRecord = try await database.save(record)
        
        let user = User.init(from: userRecord)
        
        return user
    }
    
    func updateNotificationId(user: User,  completion: @escaping (Error?) -> Void) {
        let record = user.record
        record["notificationId"] = OneSignal.getDeviceState().userId ?? ""
        
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
    
    func updateUserName(user: User, completion: @escaping (Error?) -> Void) {
        let record = user.record
        record["name"] = user.name.trimmingCharacters(in: [" "])
        
        database.save(record) { record, error in
            if let error = error {
                // this means that the server has a more up to date user than us, so pull it down and try again
                if error.localizedDescription.contains("oplock") {
                    Task {
                        if let newUser = try? await self.getCurrentUser(forceSync: true) {
                            newUser.name = user.name
                            self.updateUserName(user: newUser, completion: completion)
                        }
                    }
                }
                else {
                    completion(error)
                }
            }
            else {
                if let record = record {
                    user.record = record
                }
                
                completion(nil)
            }
        }
    }
    
    func updateUserGroups(user: User, groups: [CKRecord.Reference], completion: @escaping (Error?) -> Void) {
        let record = user.record

        record["groups"] = groups
        
        database.save(record) { record, error in
            if let error = error {
                // this means that the server has a more up to date user than us, so pull it down and try again
                if error.localizedDescription.contains("oplock") {
                    Task {
                        if let newUser = try? await self.getCurrentUser(forceSync: true) {
                            newUser.groups = user.groups
                            self.updateUserGroups(user: user, groups: groups, completion: completion)
                        }
                    }
                }
                else {
                    completion(error)
                }
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
                    // this means that the server has a more up to date user than us, so pull it down and try again
                    if error.localizedDescription.contains("oplock") {
                        Task {
                            if let newUser = try? await self.getCurrentUser(forceSync: true) {
                                newUser.photo = user.photo
                                self.updateUserImage(user: newUser, completion: completion)
                            }
                        }
                    }
                    else {
                        completion(error)
                    }
                }
                else {
                    if let record = record {
                        user.record = record
                    }

                    completion(nil)
                }
            }
        }
        else {
            completion(nil)
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
        
        let groupIds = user.groups.map { $0.recordID }
        
        if groupIds.isEmpty {
            completion([])
            return
        }
        
        let predicate = NSPredicate(format: "recordID in %@", groupIds)
        let query = CKQuery(recordType: "Group", predicate: predicate)
        
        database.fetch(withQuery: query) { [weak self] result in
            switch result {
            case .success(let (matches,_)):
                var groupsToAdd = [UserGroup]()
                
                for match in matches {
                    switch match.1 {
                    case .success(let record):
                        if let group = UserGroup.init(from: record) {
                            groupsToAdd.append(group)
                        }
                    case .failure(_):
                        completion(nil)
                    }
                }
                
                self?.currentGroups = groupsToAdd
                
                completion(groupsToAdd)
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
        
        let activities = records.compactMap { Activity.init(from: $0) }
        
        return await removeDuplicateActivities(activities: activities)
    }
    
    func removeDuplicateActivities(activities: [Activity]) async -> [Activity] {
        // get newest at top
        let activities = activities.sorted(by: { $0.createdAt > $1.createdAt })
        var uniqueActivities = [Activity]()
        var activitiesToRemove = [Activity]()
        
        for activity in activities {
            // if its custom, the name can be the same but the unit can be different so we check both
            if uniqueActivities.contains(where: { $0.name == activity.name && $0.unit == activity.unit }) {
                activitiesToRemove.append(activity)
            }
            else {
                uniqueActivities.append(activity)
            }
        }
       
        // remove any duplicates
        for activity in activitiesToRemove {
            try? await deleteRecord(recordId: activity.record.recordID)
        }
       
        return uniqueActivities
    }
        
    func getChallengesForUser(currentChallenges: [Challenge]) async throws -> [Challenge]? {
        if let user = try await getCurrentUser(forceSync: false) {
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [
                NSPredicate(format: "users CONTAINS %@", user.record),
                NSPredicate(format: "startTime > %@", (Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()) as NSDate)
            ])
            
            let query = CKQuery(recordType: "Challenge", predicate: compoundPredicate)

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
                
                return challenges.sorted(by: { $0.startTime > $1.startTime })
            }
        }

        return nil
    }
    
    func getGroupFromChallenge(challenge: Challenge, completion: @escaping (UserGroup?) -> Void) {
        database.fetch(withRecordID: challenge.groupRecord.recordID) { groupRecord, error in
            if let error = error {
                if error.localizedDescription.contains("not found") {
                    let group = UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "Group Deleted", owner: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"))
                    
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
    
    func deleteGroup(recordId: CKRecord.ID, completion: @escaping (Error?) -> Void) {
        deleteRecord(recordId: recordId) { [weak self] error in
            if let error = error {
                completion(error)
            }
            else {
                self?.currentGroups?.removeAll(where: { $0.record.recordID == recordId })
                self?.removeUserFromGroup(recordId: recordId) { error in
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
    
    func deleteRecord(recordId: CKRecord.ID) async throws {
        try await database.deleteRecord(withID: recordId)
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
        record.setValue(UserGroup.availableDays(deliveryTime: group.deliveryTime, displayedDays: group.displayedDays), forKey: "availableDays")
        record.setValue(group.displayedDays, forKey: "displayedDays")
        record.setValue(getTodayAtTimeOf(date: group.deliveryTime), forKey: "deliveryTime")
        record.setValue(color.rawValue, forKey: "backgroundColor")
        
        database.save(record) { record, error in
            if let error = error {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func createGroup(name: String, emoji: String, color: GroupBackgroundColor, days: [Int], time: Date, activities: [Activity], completion: @escaping (Result<UserGroup, Error>) -> Void) {
        guard let user = cachedUser else {
            completion(.failure(NSError(domain: "User not found", code: 0)))
            return
        }
        
        let userReference = CKRecord.Reference(record: user.record, action: .none)
        let record = CKRecord(recordType: "Group")
        
        record.setValue(userReference, forKey: "owner")
        record.setValue(name, forKey: "name")
        record.setValue(emoji, forKey: "emoji")
        record.setValue(days, forKey: "displayedDays")
        record.setValue(UserGroup.availableDays(deliveryTime: time, displayedDays: days), forKey: "availableDays")
        record.setValue(time, forKey: "deliveryTime")
        record.setValue(color.rawValue, forKey: "backgroundColor")
        record.setValue(Calendar.current.timeZone.identifier, forKey: "timeZone")
        
        database.save(record) { [weak self] record, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let record = record {
                if let group = UserGroup.init(from: record) {
                    CloudKitHelper.shared.createActivities(groupRecordId: record.recordID, activities: activities) { result in
                        switch result {
                        case .success(let activities):
                            group.activities = activities
                            group.users = [user]
                            
                            self?.addUserToGroup(group: group) { error in
                                if let error = error {
                                    completion(.failure(error))
                                    return
                                }
                                
                                self?.currentGroups?.append(group)
                                completion(.success(group))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                            return
                        }
                    }
                }
            }
        }
    }
    
    func updateActivity(activity: Activity, completion: @escaping (Error?) -> Void) {
        let record = activity.record
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
    
    func removeUserFromGroup(recordId: CKRecord.ID, completion: @escaping (Error?) -> Void) {
        guard let user = cachedUser else {
            completion(NSError(domain: "User not found", code: 0))
            return
        }
        
        var groups = user.groups
        groups.removeAll(where: { recordId == $0.recordID })
        
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
    
    func addUserToGroup(group: UserGroup, completion: @escaping (Error?) -> Void) {
        guard let user = cachedUser else {
            completion(NSError(domain: "User not found", code: 0))
            return
        }
        
        let newGroupReference = CKRecord.Reference(recordID: group.record.recordID, action: .none)
        user.groups.append(newGroupReference)
        
        let record = user.record
        record.setValue(user.groups, forKey: "groups")
        
        database.save(record) { record, error in
            if let error = error {
                print(error)
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
    func createActivities(groupRecordId: CKRecord.ID, activities: [Activity], completion: @escaping (Result<[Activity], Error>) -> Void) {
        var records = [CKRecord]()
        
        for activity in activities {
            let record = CKRecord(recordType: "Activity")
            
            let groupReference = CKRecord.Reference(recordID: groupRecordId, action: .none)
            
            record.setValue(activity.templateId, forKey: "templateId")
            record.setValue(1, forKey: "isEnabled")
            record.setValue(activity.name, forKey: "name")
            record.setValue(activity.unit.rawValue, forKey: "unit")
            record.setValue(activity.unit.minValue(), forKey: "minRange")
            record.setValue(activity.minValue, forKey: "minValue")
            record.setValue(activity.maxValue, forKey: "maxValue")
            record.setValue(groupReference, forKey: "group")
            
            records.append(record)
        }
        
        database.modifyRecords(saving: records, deleting: []) { response in
            switch response {
            case .success(let results):
                var activities = [Activity]()
                
                for save in results.saveResults {
                    switch save.value {
                    case .success(let record):
                        if let activity = Activity.init(from: record) {
                            activities.append(activity)
                        }
                    case .failure(let error):
                        print(error)
                        completion(.failure(error))
                        return
                    }
                }
                
                completion(.success(activities))
            case .failure(let error):
                print(error)
                completion(.failure(error))
                return
            }
        }
    }
    
    func completeChallenge(challenge: Challenge, completion: @escaping (Error?) -> Void) {
        guard let user = cachedUser else {
            completion(NSError(domain: "Could not load user data", code: 0))
            return
        }
        
        let challengeReference = CKRecord.Reference(recordID: challenge.recordId, action: .none)
        let userReference = CKRecord.Reference(recordID: user.record.recordID, action: .none)
        
        let record = CKRecord(recordType: "CompletedChallenge")
        record.setValue(challengeReference, forKey: "challenge")
        record.setValue(challenge.groupRecord, forKey: "group")
        record.setValue(userReference, forKey: "user")
        record.setValue(challenge.amount, forKey: "amount")
        record.setValue(challenge.activityName, forKey: "activityName")
        record.setValue(challenge.unit.rawValue, forKey: "unit")
        record.setValue(Date(), forKey: "date")
        
        database.save(record) { record, error in
            if let error = error {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func usersWhoHaveCompletedChallenge(challenge: Challenge) async throws -> [User]? {
        let predicate = NSPredicate(format: "challenge = %@", challenge.recordId)
        let query = CKQuery(recordType: "CompletedChallenge", predicate: predicate)
        
        let response = try await database.records(matching: query)
            
        let records = try response.matchResults.map { try $0.1.get() }
        
        let completedChallenges = records.compactMap { CompletedChallenge.init(from: $0, group: challenge.group ?? UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "", owner: CKRecord.Reference(record: CKRecord.init(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"))) }
        
        var users = [User]()
        for completedChallenge in completedChallenges {
            let predicate = NSPredicate(format: "recordID = %@", completedChallenge.user.recordID)
            
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            let result = try await database.records(matching: query)
            
            let records = try result.matchResults.map { try $0.1.get() }
            
            users.append(contentsOf: records.compactMap({ User.init(from: $0) }))
        }
                    
        return users
    }
    
    var challenges = [CKRecord.ID: [CompletedChallenge]]()
    func fetchCompletedChallenges(group: UserGroup, forceSync: Bool, completion: @escaping (Result<[CompletedChallenge], Error>) -> Void) {
        if !challenges.isEmpty && !forceSync {
            if let groupChallenges = challenges.first(where: { $0.key == group.record.recordID })?.value {
                completion(.success(groupChallenges))
            }
        }
        
        let groupReference = CKRecord.Reference(record: group.record, action: .none)
        let predicate = NSPredicate(format: "group = %@", groupReference)
        let query = CKQuery(recordType: "CompletedChallenge", predicate: predicate)

        getAllCompletedChallengeRecords(group: group, records: [], query: query, cursor: nil, completion: completion)
    }
    
    func getAllCompletedChallengeRecords(group: UserGroup, records: [CKRecord], query: CKQuery?, cursor: CKQueryOperation.Cursor?, completion: @escaping (Result<[CompletedChallenge], Error>) -> Void) {
        var records = records
        
        let queryOperation: CKQueryOperation? = {
            if let query {
                return CKQueryOperation(query: query)
            }
            
            if let cursor {
                return CKQueryOperation(cursor: cursor)
            }
            
            return nil
        }()
        
        guard let queryOperation else { return }
        
        queryOperation.resultsLimit = CKQueryOperation.maximumResults;
        queryOperation.recordMatchedBlock = {
            if let record = try? $1.get() {
                records.append(record)
            }
        }
        
        queryOperation.queryResultBlock = { [self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let cursor):
                
                if let cursor  {
                    getAllCompletedChallengeRecords(group: group, records: records, query: nil, cursor: cursor, completion: completion)
                } else {
                    completion(.success(records.compactMap({ CompletedChallenge(from: $0, group: group) })))
                }
            }
        }
        
        database.add(queryOperation)
    }
    
    func sendUsersNotifications(challenge: Challenge) async throws {
        guard let user = cachedUser else {
            return
        }
        
        let device = OneSignal.getDeviceState()
        
        let playerIds = challenge.users?.map({ $0.notificationId }).filter({ $0 != device?.userId ?? "" }) ?? []
        
        let notification: [String: Any] = [
            "app_id": "f211cce4-760d-4404-97f3-34df31eccde8",
            "include_player_ids": playerIds,
            "contents": ["en": "\(user.name) completed today's challenge for \(challenge.group?.name ?? "") \(challenge.group?.emoji ?? "")"],
            "headings": ["en": "Challenge Completed"]
        ]
        
        OneSignal.postNotification(notification)
    }
    
    func getStreakForGroup(group: UserGroup) async -> Int {
        var challenges = await withCheckedContinuation { continuation in
            getAllChallengesForGroup(group: group) { result in
                switch result {
                case .failure(let error):
                    print(error)
                    continuation.resume(returning: [Challenge]())
                case .success(let challenges):
                    continuation.resume(returning: challenges)
                }
            }
        }
        
        challenges.sort(by: { $0.startTime > $1.startTime })
        
        var streak = 0
        for challenge in challenges {
            if let completions = try? await usersWhoHaveCompletedChallenge(challenge: challenge) {
                if completions.count >= challenge.userRecords.count {
                    streak += 1
                }
                else {
                    if challenge.isChallengeTimeUp() {
                        break
                    }
                }
            }
        }
        
        return streak
    }
    
    func getAllChallengesForGroup(group: UserGroup, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        let groupReference = CKRecord.Reference(record: group.record, action: .none)
        let predicate = NSPredicate(format: "group = %@", groupReference)
        let query = CKQuery(recordType: "Challenge", predicate: predicate)

        getAllChallengeRecords(records: [], query: query, cursor: nil, completion: completion)
    }
    
    // TODO: only certain fields using queryOperation.desiredKeys
    func getAllChallengeRecords(records: [CKRecord], query: CKQuery?, cursor: CKQueryOperation.Cursor?, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        var records = records
        
        let queryOperation: CKQueryOperation? = {
            if let query {
                return CKQueryOperation(query: query)
            }
            
            if let cursor {
                return CKQueryOperation(cursor: cursor)
            }
            
            return nil
        }()
        
        guard let queryOperation else { return }
        
        queryOperation.resultsLimit = CKQueryOperation.maximumResults;
        queryOperation.recordMatchedBlock = {
            if let record = try? $1.get() {
                records.append(record)
            }
        }
        
        queryOperation.queryResultBlock = { [self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let cursor):
                
                if let cursor  {
                    getAllChallengeRecords(records: records, query: nil, cursor: cursor, completion: completion)
                } else {
                    completion(.success(records.compactMap({ Challenge(from: $0) })))
                }
            }
        }
        
        database.add(queryOperation)
    }
}
