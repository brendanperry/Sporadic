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
        let run = Activity(
            id: 0,
            name: Localize.getString("Run"),
            minValue: 0.25,
            maxValue: 10,
            total: 24,
            isEnabled: true)
        let bike = Activity(
            id: 1,
            name: Localize.getString("Bike"),
            minValue: 0.1,
            maxValue: 50,
            total: 57,
            isEnabled: false)
        let yoga = Activity(
            id: 2,
            name: Localize.getString("Bike"),
            minValue: 0.1,
            maxValue: 50,
            total: 57,
            isEnabled: false)
        let meditate = Activity(
            id: 3,
            name: Localize.getString("Bike"),
            minValue: 0.1,
            maxValue: 50,
            total: 57,
            isEnabled: false)
        let hike = Activity(
            id: 4,
            name: Localize.getString("Bike"),
            minValue: 0.1,
            maxValue: 50,
            total: 57,
            isEnabled: false)

        return [run, bike, yoga, meditate, hike]
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

    func activityCheckmarkClicked(activityId: Int, isOn: Bool) {
        activities[activityId].isEnabled = isOn

        self.saveActivities(activities: activities)

        notificationHelper.scheduleAllNotifications(activities: activities)
    }

    func scheduleNotifs() {
        notificationHelper.scheduleAllNotifications(activities: activities)
    }
}
