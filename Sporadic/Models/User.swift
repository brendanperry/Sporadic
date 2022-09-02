//
//  User.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

class User: Identifiable {
    let id = UUID()
    let recordId: CKRecord.ID
    let usersRecordId: String
    let name: String
//    let photo: String
    
    init(recordId: CKRecord.ID, usersRecordId: String, name: String) {
        self.recordId = recordId
        self.usersRecordId = usersRecordId
        self.name = name
//        self.photo = photo
    }
}

extension User {
    convenience init? (from record: CKRecord) {
        guard
            let name = record["name"] as? String,
//            let photo = record["photo"] as? CKAsset,
            let usersRecordId = record["usersRecordId"] as? String
        else {
            return nil
        }
        
        self.init(recordId: record.recordID, usersRecordId: usersRecordId, name: name)
    }
}
