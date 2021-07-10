//
//  NotificationHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/1/21.
//

import Foundation
import UserNotifications

class NotificationHelper {
    let localData = LocalDataHelper()
    let center = UNUserNotificationCenter.current()
    
    func scheduleAllNotifications(activities: [Activity]) {
        if (!isAuthorizedToSendNotifications() || activities.count == 0) {
            return
        }
        
        center.removeAllPendingNotificationRequests()
        
        let deliveryDate = localData.getDate(key: UserPrefs.DeliveryTime.rawValue)
        let deliveryDateComponents = getComponentsFromDate(deliveryDate)
        
        let todayComponents = getCurrentDate(hour: deliveryDateComponents.hour!, minutes: deliveryDateComponents.minute!)
        let today = NSCalendar.current.date(from: todayComponents)!
        
        var availableDays = [0, 1, 2, 3, 4, 5, 6]
        
        let defaults = UserDefaults()
        
        let daysPerWeek = defaults.integer(forKey: UserPrefs.DaysPerWeek.rawValue)
        //let daysPerWeek = localData.get(defaultValue: 3, key: UserPrefs.DaysPerWeek.rawValue)

        // we will need to schedule weeks in advance and figure out when to add new ones
        
        for _ in 0..<daysPerWeek {
            let daysToAdd = availableDays.randomElement()
            
            if let days = daysToAdd {
                availableDays = removeElement(days, from: availableDays)
                            
                let scheduledDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
                
                let loadedActivity = localData.get(defaultValue: Activity(), key: "0")
                
                let randomNum = round(Float.random(in: loadedActivity.minValue...loadedActivity.maxValue) * 100) / 100.0
                
                scheduleNotification(title: "Your Challenge For Today", body: "\(loadedActivity.name) for \(randomNum) miles.", dateTime: getComponentsFromDate(scheduledDate))
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
    
    internal func getCurrentDate(hour: Int, minutes: Int) -> DateComponents {
        var components = getComponentsFromDate(Date())
        
        components.hour = hour;
        components.minute = minutes;
        components.second = 0;
        components.timeZone = TimeZone.current
        
        return components;
    }
    
    internal func getComponentsFromDate(_ date: Date) -> DateComponents {
        let requestedComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        
        return Calendar.current.dateComponents(requestedComponents, from: date)
    }
    
    internal func removeElement(_ target: Int, from list: [Int]) -> [Int] {
        var newList = list
        
        for (index, element) in newList.enumerated() {
            if (element == target) {
                newList.remove(at: index)
                return newList;
            }
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
