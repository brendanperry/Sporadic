//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

class Activity: Identifiable, Equatable, Hashable, ObservableObject {
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.record.recordID == rhs.record.recordID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(record.recordID)
    }
    
    let record: CKRecord
    @Published var maxValue: Double
    @Published var minValue: Double
    var name: String
    var templateId: Int
    var unit: ActivityUnit
    var group: CKRecord.Reference?
    @Published var wasEdited = false
    @Published var wasDeleted = false
    var isNew = false
    var createdAt = Date()
    var template: ActivityTemplate? = nil
    
    internal init(record: CKRecord, maxValue: Double, minValue: Double, name: String, templateId: Int, unit: ActivityUnit, group: CKRecord.Reference? = nil, wasEdited: Bool = false, wasDeleted: Bool = false, isNew: Bool = false, createdAt: Date = Date()) {
        self.record = record
        self.maxValue = maxValue
        self.minValue = minValue
        self.name = name
        self.templateId = templateId
        self.unit = unit
        self.group = group
        self.wasEdited = wasEdited
        self.wasDeleted = wasDeleted
        self.isNew = isNew
        self.createdAt = createdAt
        
        self.template = ActivityTemplateHelper.getTemplate(by: templateId)
    }
}

extension Activity {
    convenience init? (from record: CKRecord) {
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
        
        self.init(record: record, maxValue: maxValue, minValue: minValue, name: name, templateId: templateId, unit: ActivityUnit.init(rawValue: unit) ?? .miles, group: group)
    }
}
