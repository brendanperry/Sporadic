//
//  GroupEntity.swift
//  Sporadic
//
//  Created by brendan on 1/1/24.
//

import Foundation
import AppIntents
import CloudKit

struct GroupEntity: AppEntity {
    var id: String
    let name: String
    let emoji: String
    let color: Int
    let groupRecord: CKRecord
    
    static var defaultQuery = GroupEntityQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Group"
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: name)
    }
}

struct GroupEntityQuery: EntityQuery {
    func entities(for identifiers: [GroupEntity.ID]) async throws -> [GroupEntity] {
        if let groups = try? await CloudKitHelper.shared.getGroupsForUser() {
            let groupsForIds = groups.filter({ identifiers.contains($0.record.recordID.recordName) })
            
            return groupsForIds.map {
                return GroupEntity(id: $0.record.recordID.recordName, name: $0.name, emoji: $0.emoji, color: $0.backgroundColor, groupRecord: $0.record)
            }
        }
        
        return []
    }
    
    func suggestedEntities() async throws -> [GroupEntity] {
        if let groups = try? await CloudKitHelper.shared.getGroupsForUser() {
            return groups.map {
                GroupEntity(id: $0.record.recordID.recordName, name: $0.name, emoji: $0.emoji, color: $0.backgroundColor, groupRecord: $0.record)
            }
        }
        
        return []
    }
    
    func defaultResult() async -> GroupEntity? {
        return try? await suggestedEntities().first
    }
}
