//
//  Invite.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import Foundation
import CloudKit

struct Invite: Identifiable {
    let id = UUID()
    let sentBy: Date
    let user: CKRecord.Reference
    let group: CKRecord.Reference
}
