//
//  ActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/30/21.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activities = [Activity]()
    var notificationHelper = NotificationHelper()
    var localDataHelper = LocalDataHelper()
    
    init() {
        activities = getInitializeActivities()
        activities = getLoadedActivities(activities: activities)
    }
    
    func getInitializeActivities() -> [Activity] {
        var initializedActivityList = [Activity]()
        
        let run = Activity(id: 0, unit: Unit.MilesOrKilometers, name: "Run", minValue: 0.1, maxValue: 26.2, total: 24, isEnabled: true)
        
        let bike = Activity(id: 1, unit: Unit.MilesOrKilometers, name: "Bike", minValue: 0.1, maxValue: 50, total: 57, isEnabled: false)
        
        initializedActivityList.append(run)
        initializedActivityList.append(bike)
        
        return initializedActivityList
    }
    
    func getLoadedActivities(activities: [Activity]) -> [Activity] {
        var loadedActivities = [Activity]()
        
        for activity in activities {
            let loadedActivity = localDataHelper.get(data: activity, key: activity.name)
            
            loadedActivities.append(loadedActivity)
        }
        
        return loadedActivities
    }
    
    func saveActivities(activities: [Activity]) {
        for activity in activities {
            localDataHelper.save(data: activity, key: activity.name)
        }
    }
    
    func activityCheckmarkClicked(id: Int, isOn: Bool) {
        activities[id].isEnabled = isOn
        
        self.saveActivities(activities: activities)
    }
}
