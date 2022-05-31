//
//  AddActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation

class AddActivityViewModel : ObservableObject {
//    let dataController: DataController
//    let activityTemplateHelper: ActivityTemplateHelper
    
    @Published var activities = [Activity]()
    
//    init(dataController: DataController,
//         activityTemplateHelper: ActivityTemplateHelper) {
//        self.dataController = dataController
//        self.activityTemplateHelper = activityTemplateHelper
//
//        DispatchQueue.main.async { [weak self] in
//            if let activities = self?.getDisabledActivities() {
//                self?.activities = activities
//            }
//        }
//    }
    
    func getDisabledActivities() -> [Activity] {
//        let activities = dataController.fetchInactiveActivities()
        
//        if let activities = activities {
//            if activities.count > 0 {
//
//                return activities
//            }
//        }
//
//        return activityTemplateHelper.getAndCreateDefaultActivities()
        
        return []
    }
}
