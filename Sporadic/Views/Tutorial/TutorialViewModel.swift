//
//  TutorialViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/30/23.
//

import Foundation
import CloudKit
import UIKit


class TutorialViewModel: ObservableObject {
    @Published var selectedDifficulty = GroupDifficulty.beginner
    @Published var name = ""
    @Published var photo: UIImage? = nil
    @Published var group = UserGroup(displayedDays: [], deliveryTime: Date(), emoji: "", backgroundColor: 0, name: "Group Deleted", owner: CKRecord.Reference(record: CKRecord(recordType: "User"), action: .none), record: CKRecord(recordType: "Group"))


}
