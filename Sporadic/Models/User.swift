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
    let recordId: CKRecord.ID
    let usersRecordId: String
    var name: String
    var photo: UIImage?
    
    init(recordId: CKRecord.ID, usersRecordId: String, name: String, photo: UIImage?) {
        self.recordId = recordId
        self.usersRecordId = usersRecordId
        self.name = name
        self.photo = photo
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension User {
    convenience init? (from record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let usersRecordId = record["usersRecordId"] as? String
        else {
            return nil
        }
        
        var photo: UIImage? = nil
        if let asset = record["photo"] as? CKAsset {
            photo = asset.toUIImage()
        }
        
        self.init(recordId: record.recordID, usersRecordId: usersRecordId, name: name, photo: photo)
    }
}
