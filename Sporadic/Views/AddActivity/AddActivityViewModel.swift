//
//  AddActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation
import Combine

class AddActivityViewModel: ObservableObject {
    @Published var name = ""
    @Published var unit = ActivityUnit.miles
    @Published var minValue = 1.0
    @Published var maxValue = 3.0
    
    let unitPublisher = PassthroughSubject<ActivityUnit, Never>()
    let notificationHelper = NotificationHelper(cloudKitHelper: CloudKitHelper.shared)
    
    let group: UserGroup
    
    init(group: UserGroup) {
        self.group = group
    }
    
    func resetSlider(newUnit: ActivityUnit) {
        unitPublisher.send(newUnit)
    }
    
    func addActivity(completion: @escaping (Error?) -> Void) {
        CloudKitHelper.shared.addActivityToGroup(groupRecordId: group.recordId, name: name, unit: unit.toAbbreviatedString(), minValue: minValue, maxValue: maxValue) { [weak self] error in
            if error == nil {
                self?.notificationHelper.scheduleAllNotifications(settingsChanged: true)
            }
            
            completion(error)
        }
    }
}
