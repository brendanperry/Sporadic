//
//  AddActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation
import CoreData

class AddActivityViewModel : ObservableObject {
    let dataController: DataController
    let activityTemplateHelper: ActivityTemplateHelper
    
    @Published var activities = [Activity]()
    
    init(dataController: DataController, activityTemplateHelper: ActivityTemplateHelper) {
        self.dataController = dataController
        self.activityTemplateHelper = activityTemplateHelper
            
        activities = getDisabledActivities()
    }
    
    func getDisabledActivities() -> [Activity] {
        let fetchRequest = Activity.fetchRequest()
        
        let activities = try? dataController.controller.viewContext.fetch(fetchRequest)
        
        if let activities = activities {
            if activities.count != 0 {
                return activities.filter { activity in
                    return activity.isEnabled == false
                }
            }
        }
        
        return activityTemplateHelper.getDefaultActivities()
    }
}
