//
//  ActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/30/21.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activities = [Activity]()
    
    @Published var activityIdToEdit: Int = -1
    
    @Published var dummy: Int = 0
    
    var notificationHelper = NotificationHelper()
    var localDataHelper = LocalDataHelper()

    init() {
        self.activities = self.getInitializeActivities()
        
        self.loadActivities()
    }
    
    func dummygo() {
        dummy += 1
    }
    
    func loadActivities() {
        activities = self.getLoadedActivities(activities: activities)
    }

    func getInitializeActivities() -> [Activity] {
        let run = Activity(
            id: 0,
            name: Localize.getString("Run"),
            pastTense: "run",
            presentTense: "running",
            unit: "miles",
            unitAbbreviation: "mi",
            minValue: 0.25,
            maxValue: 10,
            minRange: 0.25,
            selectedMin: 0.5,
            selectedMax: 2,
            total: 24,
            isEnabled: true)
        let bike = Activity(
            id: 1,
            name: Localize.getString("Bike"),
            pastTense: "biked",
            presentTense: "biking",
            unit: "miles",
            unitAbbreviation: "mi",
            minValue: 0.25,
            maxValue: 50,
            minRange: 0.25,
            selectedMin: 1,
            selectedMax: 3,
            total: 12,
            isEnabled: false)
        let yoga = Activity(
            id: 2,
            name: Localize.getString("Yoga"),
            pastTense: "trained",
            presentTense: "yoga",
            unit: "minutes",
            unitAbbreviation: "min",
            minValue: 1,
            maxValue: 60,
            minRange: 1,
            selectedMin: 15,
            selectedMax: 30,
            total: 240,
            isEnabled: false)

        return [run, bike, yoga]
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
            _ = localDataHelper.save(data: activity, key: "\(activity.id)")
        }
    }
    
    func saveActivity(activity: Activity) {
        _ = localDataHelper.save(data: activity, key: "\(activity.id)")
    }

    func activityCheckmarkClicked(activityId: Int, isOn: Bool) {
        activities[activityId].isEnabled = isOn

        self.saveActivities(activities: activities)

        notificationHelper.scheduleAllNotifications(activities: activities)
    }
    
    func getActivity(byId: Int) -> Activity {
        return activities.first(where: { $0.id == byId }) ?? Activity()
    }

    func scheduleNotifs() {
        notificationHelper.scheduleAllNotifications(activities: activities)
    }
}
