//
//  Activity.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

struct Activity: Identifiable {
    let id: UUID
    var isEnabled: Bool
    var maxValue: Double
    var minValue: Double
//    var minRange: Double
    var name: String
    var templateId: Int?
    var unit: ActivityUnit
}

extension Activity {
    init? (from record: CKRecord) {
        guard
            let isEnabled = record["isEnabled"] as? Int,
            let maxValue = record["maxValue"] as? Double,
            let minValue = record["minValue"] as? Double,
//            let minRange = record["minRange"] as? Double,
            let name = record["name"] as? String,
            let templateId = record["templateId"] as? Int,
            let unit = record["unit"] as? String
        else {
            return nil
        }
        
        self = .init(id: UUID(), isEnabled: isEnabled == 0 ? false : true, maxValue: maxValue, minValue: minValue, name: name, templateId: templateId == -1 ? nil : templateId, unit: ActivityUnit.init(rawValue: unit) ?? .miles)
    }
}
