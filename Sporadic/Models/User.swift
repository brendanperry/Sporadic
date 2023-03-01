//
//  User.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit
import UIKit

class User: Identifiable, Equatable {
    let id = UUID()
    var record: CKRecord
    let usersRecordId: String
    var name: String
    var photo: UIImage?
    var groups: [CKRecord.Reference]
    var createdAt = Date()
    
    init(record: CKRecord, usersRecordId: String, name: String, photo: UIImage?, groups: [CKRecord.Reference]) {
        self.record = record
        self.usersRecordId = usersRecordId
        self.name = name
        self.photo = photo
        self.groups = groups
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension User {
    convenience init? (from record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let usersRecordId = record["usersRecordId"] as? String,
            let groups = record["groups"] as? [CKRecord.Reference]?
        else {
            return nil
        }
                
        var photo: UIImage? = nil
        if let asset = record["photo"] as? CKAsset {
            photo = asset.toUIImage()
        }
        
        self.init(record: record, usersRecordId: usersRecordId, name: name, photo: photo, groups: groups ?? [])
    }
}
