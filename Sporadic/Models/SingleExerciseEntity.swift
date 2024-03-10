//
//  SingleExerciseEntity.swift
//  Sporadic
//
//  Created by brendan on 12/16/23.
//

import Foundation
import AppIntents
import CloudKit

struct SingleExerciseEntity: AppEntity {
    var id: String
    let name: String
    let groupName: String
    let groupRecord: CKRecord
    let groupEmoji: String
    let groupColor: Int
    let activityName: String
    let activityUnit: String
    let template: ActivityTemplate?
    
    static var defaultQuery = SingleExerciseEntityQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Exercise"
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: name)
    }
}

struct SingleExerciseEntityQuery: EntityQuery {
    func entities(for identifiers: [SingleExerciseEntity.ID]) async throws -> [SingleExerciseEntity] {
        guard let ids = identifiers.first?.split(separator: ",", maxSplits: 1) else { return [] }
        if ids.count < 2 { return [] }
        
        let groupId = ids[0]
        let activityId = ids[1]
        
        if let groups = try? await CloudKitHelper.shared.getGroupsForUser() {
            if let group = groups.first(where: { groupId == $0.record.recordID.recordName }) {
                if let activities = try? await CloudKitHelper.shared.getActivitiesForGroup(group: group) {
                    if let activity = activities.first(where: { $0.record.recordID.recordName == activityId }) {
                        return [SingleExerciseEntity(id: groupId + "," + activityId, name: group.name + ": " + activity.name, groupName: group.name, groupRecord: group.record, groupEmoji: group.emoji, groupColor: group.backgroundColor, activityName: activity.name, activityUnit: activity.unit.rawValue, template: activity.template)]
                    }
                }
            }
        }
        
        return []
    }
    
    func suggestedEntities() async throws -> [SingleExerciseEntity] {
        var entities = [SingleExerciseEntity]()
        
        if let groups = try? await CloudKitHelper.shared.getGroupsForUser() {
            for group in groups {
                if let activities = try? await CloudKitHelper.shared.getActivitiesForGroup(group: group) {
                    for activity in activities {
                        let entity = SingleExerciseEntity(id: group.record.recordID.recordName + "," + activity.record.recordID.recordName, name: group.name + ": " + activity.name, groupName: group.name, groupRecord: group.record, groupEmoji: group.emoji, groupColor: group.backgroundColor, activityName: activity.name, activityUnit: activity.unit.rawValue, template: activity.template)
                        entities.append(entity)
                    }
                }
                
                
            }
        }
        
        return entities
    }
    
    func defaultResult() async -> SingleExerciseEntity? {
        return try? await suggestedEntities().first
    }
}
