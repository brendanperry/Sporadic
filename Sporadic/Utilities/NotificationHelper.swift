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
    let context: NSManagedObjectContext
    let defaults = UserDefaults()
    let notificationCenter = UNUserNotificationCenter.current()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func scheduleAllNotifications() {
//        if !isAuthorizedToSendNotifications() || activities.count == 0 {
//            return
//        }
        
        let fetch = Activity.fetchRequest()
        
        let activities = try? context.fetch(fetch)
        
        if let activities = activities {
            notificationCenter.removeAllPendingNotificationRequests()

            var today = getToday()
            let daysPerWeek = defaults.integer(forKey: UserPrefs.daysPerWeek.rawValue)
            let weeksToSchedule = 12;
            
            for week in 0..<weeksToSchedule {
                print("Week \(week)")
                today = Calendar.current.date(byAdding: .day, value: 7, to: today)!
                
                var availableDays = [0, 1, 2, 3, 4, 5, 6]

                scheduleOnDays(daysPerWeek, &availableDays, today, activities)
                
                print("")
            }
            
            scheduleReminder(date: today)
        }
    }
    
    internal func scheduleReminder(date: Date) {
        let finalDate = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        
        print("\(finalDate) - reminder")
        
        scheduleNotification(
            title: "We miss you!",
            body: "Come back to the app to get more challenges.",
            dateTime: getComponentsFromDate(finalDate))
    }
    
    internal func scheduleOnDays(_ daysPerWeek: Int, _ availableDays: inout [Int], _ today: Date, _ activities: [Activity]) {
        for _ in 0..<daysPerWeek {
            let daysToAdd = availableDays.randomElement()
            
            if let days = daysToAdd {
                availableDays = removeElement(days, from: availableDays)
                
                let scheduledDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
                
                let activity = activities[Int.random(in: 0..<activities.count)]
                
                let amount = round(Double.random(in: activity.selectedMin...activity.selectedMax) * 100) / 100.0
                
                let challenge = Challenge(context: context)
                challenge.amount = amount
                challenge.time = scheduledDate
                challenge.isCompleted = false
                challenge.oneChallengeToOneActivity = activity
                
                try? context.save()
                
                print("\(scheduledDate) - \(activity.name ?? "Unknown"): \(amount)")
                
                scheduleNotification(
                    title: "Your Challenge For Today",
                    body: "\(activity.name ?? "Unknown") for \(amount) miles.",
                    dateTime: getComponentsFromDate(scheduledDate))
            }
        }
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
        components.timeZone = TimeZone.current

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
