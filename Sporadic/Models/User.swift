//
//  User.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

struct User: Identifiable {
    let id = UUID()
    let recordId: NSObject
    let name: String
    let photo: CKAsset
}

extension User {
    init? (from record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let photo = record["photo"] as? CKAsset
        else {
            return nil
        }
        
        self.init(recordId: record.recordID, name: name, photo: photo)
    }
}
