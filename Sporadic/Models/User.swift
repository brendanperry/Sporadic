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
    let recordId: CKRecord.ID
    let usersRecordId: String
    let name: String
    let photo: String
}

extension User {
    init? (from record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let photo = record["photo"] as? CKAsset,
            let usersRecordId = record["usersRecordId"] as? String
        else {
            return nil
        }
        
        self.init(recordId: record.recordID, usersRecordId: usersRecordId, name: name, photo: "")
    }
}
