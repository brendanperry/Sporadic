//
//  NotificationHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/1/21.
//

import Foundation
import UserNotifications
import CoreData

class NotificationHelper {
    let dataHelper: Repository
    let defaults = UserDefaults()
    let notificationCenter = UNUserNotificationCenter.current()
    let dateFormatter = DateFormatter()
    let maxNotificationsToSchedule = 90
    let oneSignalHelper = OneSignalHelper()
    
    init(dataHelper: Repository) {
        self.dataHelper = dataHelper
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
    }
    
    func scheduleAllNotifications(settingsChanged: Bool) {
        getNotificationStatus { [weak self] authorized in
            if authorized {
                DispatchQueue.main.async {
                    self?.beginScheduling(settingsChanged)
                }
            }
            
            GlobalSettings.Env.updateStatus()
        }
    }
    
    internal func beginScheduling(_ settingsChanged: Bool) {
        var challengesScheduled = [Challenge]()
        var notificationIdsToCancel = [String]()
        let activities = dataHelper.fetchActiveActivities()
        
        var dateToBeginScheduling = getToday()
        
        // remove things at the end all at once
        if settingsChanged {
            notificationIdsToCancel.append(contentsOf: removeOldChallenges())
        } else {
            if let finalChallengeDate = dataHelper.getDayAfterLastChallenge() {
               dateToBeginScheduling = finalChallengeDate
            }
        }
        
        // OneSignal has a limit of 30 days out
        let lastDayWeCanSchedule = Calendar.current.date(byAdding: .day, value: 28, to: getToday()) ?? Date()
        
        if let activities = activities {
            if activities.count == 0 {
                postNotifications(notificationIdsToCancel, challengesScheduled)
                return
            }

            // will pull this per group
            var daysPerWeek = defaults.integer(forKey: UserPrefs.daysPerWeek.rawValue)
            if daysPerWeek == 0 {
                daysPerWeek = 3
            }
            
            let currentChallenge = dataHelper.fetchCurrentChallenge()
            
            var continueScheduling = true
            var i = 0
            while continueScheduling {
                var availableDays = [Int]()
                
                // this keeps us from scheduling a challenge today if there is already one
                if i == 0 && currentChallenge != nil {
                    availableDays = [1, 2, 3, 4, 5, 6]
                } else {
                    availableDays = [0, 1, 2, 3, 4, 5, 6]
                }
                
                let result = scheduleOnDays(maxScheduleDate: lastDayWeCanSchedule, daysPerWeek, &availableDays, dateToBeginScheduling, activities)

                continueScheduling = result.0
                challengesScheduled.append(contentsOf: result.1)
                
                dateToBeginScheduling = Calendar.current.date(byAdding: .day, value: 7, to: dateToBeginScheduling)!
                i += 1
            }
            
            postNotifications(notificationIdsToCancel, challengesScheduled)
        }
    }
    
    func postNotifications(_ notificationIdsToCancel: [String], _ challengesScheduled: [Challenge]) {
        // schedule notifications
        oneSignalHelper.postNotification(cancelledNotificationIds: notificationIdsToCancel, challenges: challengesScheduled) { result in
            
            // store notification id on challenge object if we need to cancel later
            for (challenge, notification) in zip(challengesScheduled, result) {
                challenge.notification = notification
            }
        }
    }
    
    // returns true if we should keep going and false if we should stop
    internal func scheduleOnDays(maxScheduleDate: Date, _ daysPerWeek: Int, _ availableDays: inout [Int], _ startDate: Date, _ activities: [Activity]) -> (Bool, [Challenge]) {
        var challengesScheduled = [Challenge]()
        
        for _ in 0..<daysPerWeek {
            let daysToAdd = availableDays.randomElement()
            
            if let days = daysToAdd {
                availableDays = removeElement(days, from: availableDays)
                
                let scheduledDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!
                
                if scheduledDate > maxScheduleDate {
                    return (false, challengesScheduled)
                }
                
                let activity = activities[Int.random(in: 0..<activities.count)]
                let amount = round(Double.random(in: activity.minValue...activity.maxValue), toNearest: activity.minRange)
                
                let challenge = dataHelper.createChallenge(
                    amount: amount,
                    time: scheduledDate,
                    isCompleted: false,
                    activity: activity)
                
                challengesScheduled.append(challenge)
                
                print("\(scheduledDate) - \(activity.name ?? "Unknown"): \(amount)")
            }
        }
        
        return (true, challengesScheduled)
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        let rounded = Darwin.round(value / toNearest) * toNearest

        return rounded == -0 ? 0 : rounded
    }
//
//    func getNotificationTime(date: Date) -> Date {
//        let dateString = dateFormatter.string(from: Calendar.current.startOfDay(for: date))
//
//    }
//
//    internal func scheduleNotification(title: String, body: String, dateTime: Date, completion: @escaping(String?) -> Void) {
//        let dateString = dateFormatter.string(from: Calendar.current.startOfDay(for: dateTime))
//        var timeString = ""
//        if let deliveryTime = UserDefaults.standard.object(forKey: UserPrefs.deliveryTime.rawValue) as? Date {
//            let date = Calendar.current.dateComponents([.hour, .minute], from: deliveryTime)
//            timeString = "\(date.hour ?? 0) \(date.minute ?? 0)"
//        }
//    }
    
    fileprivate func removeOldChallenges() -> [String] {
        return dataHelper.removeAllPendingChallenges()
    }
    
    internal func getToday() -> Date {
        let deliveryDate = getDate(key: UserPrefs.deliveryTime.rawValue)
            
        let deliveryDateComponents = getComponentsFromDate(deliveryDate)

        let todayComponents = getCurrentDate(
            hour: deliveryDateComponents.hour!,
            minutes: deliveryDateComponents.minute!)

        return NSCalendar.current.date(from: todayComponents)!
    }
    
    func getDate(key: String) -> Date {
        let data = defaults.object(forKey: key) as? String

        if let stringDate = data {
            if let date = Date(rawValue: stringDate) {
                return date
            }
        }

        return Date()
    }

    internal func getCurrentDate(hour: Int, minutes: Int) -> DateComponents {
        var components = getComponentsFromDate(Date())

        components.hour = hour
        components.minute = minutes
        components.second = 0

        return components
    }

    internal func getComponentsFromDate(_ date: Date) -> DateComponents {
        let requestedComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]

        return Calendar.current.dateComponents(requestedComponents, from: date)
    }

    internal func removeElement(_ target: Int, from list: [Int]) -> [Int] {
        var newList = list

        for (index, element) in newList.enumerated() where element == target {
            newList.remove(at: index)

            return newList
        }

        return newList
    }
    
    func getNotificationStatus(completion: @escaping(Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
}
