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
        activities = self.getInitializeActivities()
        activities = self.getLoadedActivities(activities: activities)
    }
    
    func getInitializeActivities() -> [Activity] {
        var initializedActivityList = [Activity]()
        
        let run = Activity(id: 0, unit: Unit.MilesOrKilometers, name: Localize.getString("Run"), minValue: 0.1, maxValue: 26.2, total: 24, isEnabled: true)
        let bike = Activity(id: 1, unit: Unit.MilesOrKilometers, name: Localize.getString("Bike"), minValue: 0.1, maxValue: 50, total: 57, isEnabled: false)
        
        initializedActivityList.append(run)
        initializedActivityList.append(bike)
        
        return initializedActivityList
    }
    
    func getLoadedActivities(activities: [Activity]) -> [Activity] {
        var loadedActivities = [Activity]()
        
        for activity in activities {
            let loadedActivity = localDataHelper.get(defaultValue: activity, key: "\(activity.id)")
            
            loadedActivities.append(loadedActivity)
        }
        
        return loadedActivities
    }
    
    func saveActivities(activities: [Activity]) {
        for activity in activities {
            let _ = localDataHelper.save(data: activity, key: "\(activity.id)")
        }
    }
    
    func activityCheckmarkClicked(id: Int, isOn: Bool) {
        activities[id].isEnabled = isOn
        
        self.saveActivities(activities: activities)
        
        notificationHelper.scheduleAllNotifications(activities: activities)
    }
    
    func scheduleNotifs() {
        notificationHelper.scheduleAllNotifications(activities: activities)
    }
}
