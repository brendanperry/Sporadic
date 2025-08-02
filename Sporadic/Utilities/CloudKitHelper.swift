//
//  CloudKitHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit
import OneSignalFramework


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
            
            if isInWidget() == false {
                if let userId = cachedUser?.usersRecordId {
                    OneSignal.login(userId)
                }
                
                if cachedUser?.notificationId != OneSignal.User.pushSubscription.id {
                    if let user = cachedUser {
                        CloudKitHelper.shared.updateNotificationId(user: user) { error in
                            if let error {
                                print(error)
                            }
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
    
    func isInWidget() -> Bool {
        guard let extesion = Bundle.main.infoDictionary?["NSExtension"] as? [String: String] else { return false }
        guard let widget = extesion["NSExtensionPointIdentifier"] else { return false }
        return widget == "com.apple.widgetkit-extension"
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
        record.setValue(OneSignal.User.pushSubscription.id ?? "", forKey: "notificationId")
        
        let userRecord = try await database.save(record)
        
        let user = User.init(from: userRecord)
        
        return user
    }
    
    // TODO: Have one func to save user that handles the oplock error
    func updateNotificationId(user: User, completion: @escaping (Error?) -> Void) {
        let record = user.record
        record["notificationId"] = OneSignal.User.pushSubscription.id ?? ""
        
        database.save(record) { record, error in
            if let error = error {
                // this means that the server has a more up to date user than us, so pull it down and try again
                if error.localizedDescription.contains("oplock") {
                    Task {
                        if let newUser = try? await self.getCurrentUser(forceSync: true) {
                            self.updateNotificationId(user: newUser, completion: completion)
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
            if let error {
                print(error)
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
            let groupIds = user.groups.map { $0.recordID }
            
            if groupIds.count == 0 { return [] }
            
            let predicate = NSPredicate(format: "recordID in %@", groupIds)
            
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
                    let group = UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "Group Deleted", owner: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"), streak: 0, bestStreak: 0)
                    
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
    
    func updateGroupStreak(group: UserGroup, completion: @escaping (Error?) -> Void) {
        let record = group.record
        
        record.setValue(group.streak, forKey: "streak")
        record.setValue(group.brokenStreakDate, forKey: "brokenStreakDate")
        
        database.save(record) { record, error in
            if let error = error {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func createChallenge(group: UserGroup, completion: @escaping (Error?) -> Void) {
        guard let user = getCachedUser() else {
            completion(NSError(domain: "Failed to get user", code: 404))
            return
        }
        
        guard let activity = group.activities.randomElement() else {
            completion(NSError(domain: "Failed to get activity", code: 404))
            return
        }
        
        let amount = activity.template?.selectedMin ?? 0
        
        let userReference = CKRecord.Reference(record: user.record, action: .none)
        let activityReference = CKRecord.Reference(record: activity.record, action: .none)
        let groupReference = CKRecord.Reference(record: group.record, action: .none)

        let challengeRecord = CKRecord(recordType: "Challenge")
        challengeRecord.setValue(groupReference, forKey: "group")
        challengeRecord.setValue([userReference], forKey: "users")
        challengeRecord.setValue(amount, forKey: "amount")
        challengeRecord.setValue(activity.name, forKey: "activityName")
        challengeRecord.setValue(activityReference, forKey: "activity")
        challengeRecord.setValue(activity.unit.rawValue, forKey: "unit")
        challengeRecord.setValue(0, forKey: "currentStreak")
        challengeRecord.setValue("", forKey: "notificationId")
        challengeRecord.setValue(Date(), forKey: "startTime")
        
        database.save(challengeRecord) { record, error in
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
        Task {
            do {
                guard let user = try await getCurrentUser(forceSync: true) else {
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
                        user.groups.removeAll(where: { $0.recordID == newGroupReference })
                        return
                    }
                    
                    completion(nil)
                }
            } catch {
                completion(error)
            }
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
        record.setValue(user.name, forKey: "username")
        record.setValue(challenge.group?.name, forKey: "groupName")
        record.setValue(challenge.group?.emoji, forKey: "groupEmoji")

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
        
        let completedChallenges = records.compactMap { CompletedChallenge.init(from: $0, group: challenge.group ?? UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "", owner: CKRecord.Reference(record: CKRecord.init(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"), streak: 0, bestStreak: 0)) }
        
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
    
    func fetchCompletedChallengesForActivity(group: UserGroup, activityName: String, activityUnit: String) async throws -> [CompletedChallenge] {
        let groupReference = CKRecord.Reference(record: group.record, action: .none)
        let groupPredicate = NSPredicate(format: "group = %@", groupReference)
        let activityNamePredicate = NSPredicate(format: "activityName = %@", activityName)
        let activityUnitPredicate = NSPredicate(format: "unit = %@", activityUnit)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, activityUnitPredicate, activityNamePredicate])
        
        let query = CKQuery(recordType: "CompletedChallenge", predicate: compoundPredicate)
        
        var records = [CompletedChallenge]()
        var queryCursor: CKQueryOperation.Cursor?
        
        repeat {
            guard let response = try? await database.records(matching: query) else { return [] }
            
            for match in response.matchResults {
                let result = match.1
                
                if let record = try? result.get() {
                    if let challenge = CompletedChallenge(from: record, group: group) {
                        records.append(challenge)
                    }
                }
            }
            
            queryCursor = response.queryCursor
        } while queryCursor != nil
        
        return records
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
    
    func loadStreakForGroup(group: UserGroup) async -> Int {
        var challenges = await withCheckedContinuation { continuation in
            getAllChallengesForGroupStreak(group: group) { result in
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
        var brokenStreakDate: Date? = nil
        for challenge in challenges {
            if let completions = try? await usersWhoHaveCompletedChallenge(challenge: challenge) {
                if completions.count >= challenge.userRecords.count {
                    streak += 1
                }
                else {
                    if challenge.isChallengeTimeUp() {
                        brokenStreakDate = challenge.startTime
                        break
                    }
                }
            }
        }
        
        let currentStreak = streak
        let brokenDate = brokenStreakDate
        await MainActor.run {
            if group.streak < currentStreak {
                group.bestStreak = currentStreak
            }

            group.streak = currentStreak
            group.brokenStreakDate = brokenDate
        }
        
        CloudKitHelper.shared.updateGroupStreak(group: group) { error in
            print(error?.localizedDescription ?? "")
        }
        
        return streak
    }
    
    func getAllChallengesForGroupStreak(group: UserGroup, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        let groupReference = CKRecord.Reference(record: group.record, action: .none)
        let groupPredicate = NSPredicate(format: "group = %@", groupReference)
        
        let predicate: NSCompoundPredicate
        if let brokenStreakDate = group.brokenStreakDate {
            let datePredicate = NSPredicate(format: "creationDate > %@", brokenStreakDate as CVarArg)
            predicate = NSCompoundPredicate(type: .and, subpredicates: [groupPredicate, datePredicate])
        } else {
            predicate = NSCompoundPredicate(type: .and, subpredicates: [groupPredicate])
        }
        
        let query = CKQuery(recordType: "Challenge", predicate: predicate)

        getAllChallengeRecords(records: [], query: query, cursor: nil, completion: completion)
    }
    
    // TODO: only certain fields using queryOperation.desiredKeys
    func getAllChallengeRecords(records: [CKRecord], query: CKQuery?, cursor: CKQueryOperation.Cursor?, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        var records = records
        
        let queryOperation: CKQueryOperation? = {
            if let query {
                let operation = CKQueryOperation(query: query)
                operation.desiredKeys = ["startTime", "users"]
                return operation
            }
            
            if let cursor {
                let operation = CKQueryOperation(cursor: cursor)
                operation.desiredKeys = ["startTime", "users"]
                return operation
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
    
    func subcribeToAllGroupCompletedChallengeNotifications() async {
        guard let currentGroups else { return }
        for group in currentGroups {
            Task {
                await subscribeToGroupCompletedChallenges(for: group)
            }
        }
    }
    
    func subscribeToGroupCompletedChallenges(for group: UserGroup) async {
        guard let user = cachedUser else {
            return
        }
        
        let id = "group-completed-challenge-\(group.record.recordID.recordName)"
        
        do {
            let _ = try await database.subscription(for: id)
            return
        } catch let error as CKError {
            // Only continue through if the item hasn't been created yet
            if error.code != .unknownItem {
                print("Failed to fetch subscription: \(error)")
                return
            }
        } catch {
            print(error)
            return
        }
        
        // exclude your own user id
        let userReference = CKRecord.Reference(record: user.record, action: .none)
        let userPredicate = NSPredicate(format: "user != %@", userReference)
        
        let groupReference = CKRecord.Reference(record: group.record, action: .none)
        let groupPredicate = NSPredicate(format: "group = %@", groupReference)
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [userPredicate, groupPredicate])
        
        let subscription = CKQuerySubscription(recordType: "CompletedChallenge", predicate: compoundPredicate, subscriptionID: id, options: .firesOnRecordCreation)

        let notification = CKSubscription.NotificationInfo()
        notification.title = "Challenge Completed"
        notification.alertLocalizationKey = "ChallengeCompletedNotificationBody"
        notification.alertLocalizationArgs = ["username", "groupName", "groupEmoji"]
        notification.desiredKeys = ["username", "groupName", "groupEmoji"]
        notification.shouldSendMutableContent = true
        notification.soundName = "default"
        notification.shouldBadge = true

        subscription.notificationInfo = notification
        
        do {
            let _ = try await database.save(subscription)
            print("Subscription made!")
        } catch {
            print(error)
        }
    }
    
    func unsubscribeToGroupCompletedChallenges(for group: UserGroup, completion: @escaping (Error?) -> Void) {
        let id = "group-completed-challenge-\(group.record.recordID.recordName)"
        
        database.fetch(withSubscriptionID: id) { [weak self] remoteSubscription, erorr in
            guard let remoteSubscriptionId = remoteSubscription?.subscriptionID else {
                // No subscription to group exists
                completion(nil)
                return
            }
            
            self?.database.delete(withSubscriptionID: remoteSubscriptionId) { id, error in
                if let error {
                    completion(error)
                } else {
                    print(id ?? "")
                    completion(nil)
                }
            }
        }
    }
}
