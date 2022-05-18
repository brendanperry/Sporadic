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
                DispatchQueue.main.sync {
                    self?.beginScheduling(settingsChanged)
                }
            }
            
            GlobalSettings.Env.updateStatus()
        }
    }
    
    internal func beginScheduling(_ settingsChanged: Bool) {
        let activities = dataHelper.fetchActiveActivities()
        
        var dateToBeginScheduling = getToday()
        
        if settingsChanged {
            removeOldChallenges()
        } else {
            if let finalChallengeDate = dataHelper.popLastScheduledChallenge() {
               dateToBeginScheduling = finalChallengeDate
            }
        }
        
        if let activities = activities {
            if activities.count == 0 {
                return
            }

            var daysPerWeek = defaults.integer(forKey: UserPrefs.daysPerWeek.rawValue)
            if daysPerWeek == 0 {
                daysPerWeek = 3
            }
            
            let weeksToSchedule = Int((90 - dataHelper.getTotalChallengesScheduled()) / 7)
            let currentChallenge = dataHelper.fetchCurrentChallenge()
            
            for index in 0..<weeksToSchedule {
                var availableDays = [Int]()
                
                // this keeps us from scheduling a challenge today if there is already one
                if index == 0 && currentChallenge != nil {
                    availableDays = [1, 2, 3, 4, 5, 6]
                } else {
                    availableDays = [0, 1, 2, 3, 4, 5, 6]
                }

                scheduleOnDays(daysPerWeek, &availableDays, dateToBeginScheduling, activities)
                
                dateToBeginScheduling = Calendar.current.date(byAdding: .day, value: 7, to: dateToBeginScheduling)!
            }
            
            scheduleReminder(date: dateToBeginScheduling)
        }
    }
    
    internal func scheduleReminder(date: Date) {
        let finalDate = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        
        print("\(finalDate) - reminder")
        
        scheduleNotification(
            title: "There is more work to be done!",
            body: "Come back to the app to get more challenges. Notifications have been paused.",
            dateTime: finalDate) { id in
                print(id)
            }
    }
    
    internal func scheduleOnDays(_ daysPerWeek: Int, _ availableDays: inout [Int], _ startDate: Date, _ activities: [Activity]) {
        for _ in 0..<daysPerWeek {
            let daysToAdd = availableDays.randomElement()
            
            if let days = daysToAdd {
                availableDays = removeElement(days, from: availableDays)
                
                let scheduledDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!
                let activity = activities[Int.random(in: 0..<activities.count)]
                let amount = round(Double.random(in: activity.minValue...activity.maxValue), toNearest: activity.minRange)
                
                let challenge = dataHelper.createChallenge(
                    amount: amount,
                    time: scheduledDate,
                    isCompleted: false,
                    activity: activity)
                
                print("\(scheduledDate) - \(activity.name ?? "Unknown"): \(amount)")
                
                scheduleNotification(
                    title: "Your Challenge For Today",
                    body: "\(activity.name ?? "Unknown") for \(amount) \(activity.unit ?? "").",
                    dateTime: scheduledDate) { [weak self] id in
                        if let id = id {
                            self?.dataHelper.setChallengeNotification(challenge: challenge, notificationId: id)
                        }
                    }
            }
        }
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        let rounded = Darwin.round(value / toNearest) * toNearest

        return rounded == -0 ? 0 : rounded
    }
                                         
    internal func scheduleNotification(title: String, body: String, dateTime: Date, completion: @escaping(String?) -> Void) {
        let dateString = dateFormatter.string(from: Calendar.current.startOfDay(for: dateTime))
        var timeString = ""
        if let deliveryTime = UserDefaults.standard.object(forKey: UserPrefs.deliveryTime.rawValue) as? Date {
            let date = Calendar.current.dateComponents([.hour, .minute], from: deliveryTime)
            timeString = "\(date.hour ?? 0) \(date.minute ?? 0)"
        }
        
        OneSignal.postNotification(
            withJsonString:
            """
            {
                "app_id" : "f211cce4-760d-4404-97f3-34df31eccde8",
                "contents" : {
                    "en": "\(body)"
                },
                "headings" : {
                    "en": "New challenge"
                },
                "include_external_user_ids": [
                    "\(UserDefaults.standard.string(forKey: UserPrefs.userId.rawValue) ?? "")"
                ],
                "channel_for_external_user_ids": "push",
                "send_after": "\(dateString)",
                "delayed_option" : "timezone",
                "delivery_time_of_day": "\(timeString)"
            }
            """,
            onSuccess: { result in
                print("Success")
                if let result = result {
                    completion(result["id"] as? String)
                } else {
                    completion(nil)
                }
            }, onFailure: { _ in
                print("Failure")
                completion(nil)
            })
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
    
    func getNotificationStatus(completion: @escaping(Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
}
