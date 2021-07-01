//
//  ActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/30/21.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activities = [Activity]()
    
    init() {
        activities = getInitializeActivities()
        activities = getLoadedActivities(activities: activities)
    }
    
    func getInitializeActivities() -> [Activity] {
        var initializedActivityList = [Activity]()
        
        let run = Activity(unit: Unit.MilesOrKilometers, name: "Run", minValue: 0.1, maxValue: 26.2, total: 0, isEnabled: true)
        
        let bike = Activity(unit: Unit.MilesOrKilometers, name: "Bike", minValue: 0.1, maxValue: 50, total: 0, isEnabled: false)
        
        initializedActivityList.append(run)
        initializedActivityList.append(bike)
        
        return initializedActivityList
    }
    
    func getLoadedActivities(activities: [Activity]) -> [Activity] {
        var loadedActivities = [Activity]()
        
        for activity in activities {
            let loadedActivity = getDataFromDevice(activity: activity)
            
            loadedActivities.append(loadedActivity)
        }
        
        return loadedActivities
    }
    
    
    func getDataFromDevice(activity: Activity) -> Activity {
        let defaults = UserDefaults.standard
        
        do {
            if let savedData = defaults.object(forKey: activity.name) as? Data {
                let decoder = JSONDecoder()
                
                let loadedActivity = try decoder.decode(Activity.self, from: savedData)
                
                return loadedActivity;
            }
        } catch {
            print("Could not load activity from device.")
        }
        
        return activity
    }
    
    func saveDataToDevice(activity: Activity) {
        let defaults = UserDefaults.standard
        
        do {
            let encoder = JSONEncoder()
            
            let encodedActivity = try encoder.encode(activity);
            
            defaults.set(encodedActivity, forKey: activity.name)
        } catch {
            print("Could not save to device.")
        }
    }
}
