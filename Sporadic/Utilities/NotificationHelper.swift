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
    let dataHelper: DataHelper
    let defaults = UserDefaults()
    let notificationCenter = UNUserNotificationCenter.current()
    let dateFormatter = DateFormatter()
    
    init(dataHelper: DataHelper) {
        self.dataHelper = dataHelper
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
    }
    
    func scheduleAllNotifications() {
        let activities = dataHelper.fetchActiveActivities()
        
        removeOldChallenges()
        
        if let activities = activities {
            if activities.count == 0 {
                return
            }

            var today = getToday()
            let daysPerWeek = defaults.integer(forKey: UserPrefs.daysPerWeek.rawValue)
            let weeksToSchedule = 4;
            let currentChallenge = dataHelper.fetchCurrentChallenge()
            
            for index in 0..<weeksToSchedule {
                var availableDays = [Int]()
                
                // this keeps us from scheduling a challenge today if there is already one
                if index == 0 && currentChallenge != nil {
                    availableDays = [1, 2, 3, 4, 5, 6]
                } else {
                    availableDays = [0, 1, 2, 3, 4, 5, 6]
                }

                scheduleOnDays(daysPerWeek, &availableDays, today, activities)
                
                today = Calendar.current.date(byAdding: .day, value: 7, to: today)!
            }
            
            scheduleReminder(date: today)
        }
    }
    
    internal func scheduleReminder(date: Date) {
        let finalDate = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        
        print("\(finalDate) - reminder")
        
        scheduleNotification(
            title: "There is more work to be done!",
            body: "Come back to the app to get more challenges. Notifications have been paused.",
            dateTime: getComponentsFromDate(finalDate))
    }
    
    internal func scheduleOnDays(_ daysPerWeek: Int, _ availableDays: inout [Int], _ today: Date, _ activities: [Activity]) {
        for _ in 0..<daysPerWeek {
            let daysToAdd = availableDays.randomElement()
            
            if let days = daysToAdd {
                availableDays = removeElement(days, from: availableDays)
                
                let scheduledDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
                let activity = activities[Int.random(in: 0..<activities.count)]
                let amount = round(Double.random(in: activity.minValue...activity.maxValue), toNearest: activity.minRange)
                
                dataHelper.createChallenge(
                    amount: amount,
                    time: scheduledDate,
                    isCompleted: false,
                    activity: activity)
                
                print("\(scheduledDate) - \(activity.name ?? "Unknown"): \(amount)")
                
                scheduleNotification(
                    title: "Your Challenge For Today",
                    body: "\(activity.name ?? "Unknown") for \(amount) miles.",
                    dateTime: getComponentsFromDate(scheduledDate))
            }
        }
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        let rounded = Darwin.round(value / toNearest) * toNearest

        return rounded == -0 ? 0 : rounded
    }
                                         
    internal func scheduleNotification(title: String, body: String, dateTime: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.body = body
        

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateTime, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    fileprivate func removeOldChallenges() {
        notificationCenter.removeAllPendingNotificationRequests()
        
        dataHelper.removeAllPendingChallenges()
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

    // TODO: maybe refactor with async / await in new xcode?
    internal func isAuthorizedToSendNotifications() -> Bool {
        var notificationSettings: UNNotificationSettings?
        let semasphore = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            UNUserNotificationCenter.current().getNotificationSettings { setttings in
                notificationSettings = setttings
                semasphore.signal()
            }
        }

        semasphore.wait()

        if let settings = notificationSettings {
            return settings.authorizationStatus == .authorized
        } else {
            return false
        }
    }
}
