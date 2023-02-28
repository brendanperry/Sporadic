//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

struct Activity: Identifiable, Equatable {
    let id: UUID
    var recordId: CKRecord.ID? = nil
    var maxValue: Double
    var minValue: Double
    var name: String
    var templateId: Int?
    var unit: ActivityUnit
    var group: CKRecord.Reference?
    var wasEdited = false
    var wasDeleted = false
    var isNew = false
    var createdAt = Date()
}

extension Activity {
    init? (from record: CKRecord) {
        guard
            let maxValue = record["maxValue"] as? Double,
            let minValue = record["minValue"] as? Double,
            let name = record["name"] as? String,
            let templateId = record["templateId"] as? Int,
            let unit = record["unit"] as? String,
            let group = record["group"] as? CKRecord.Reference
        else {
            return nil
        }
        
        self = .init(id: UUID(), recordId: record.recordID, maxValue: maxValue, minValue: minValue, name: name, templateId: templateId == -1 ? nil : templateId, unit: ActivityUnit.init(rawValue: unit) ?? .miles, group: group)
    }
}
