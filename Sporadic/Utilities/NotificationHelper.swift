//
//  NotificationHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/1/21.
//

import Foundation
import UserNotifications

class NotificationHelper {
    var notifications = [Notification]()
    
    func scheduleNotification(notification: Notification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.content
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}

struct Notification: Codable {
    var title = "Your New Challenge!"
    var content: String
    var time: Date
}
