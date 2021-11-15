//
//  NotificationHelperTests.swift
//  SporadicTests
//
//  Created by Brendan Perry on 7/2/21.
//

import XCTest
@testable import Sporadic

class NotificationHelperTests: XCTestCase {
    let notificationHelper = TestNotificationHelper()

    func testRemoveElement() {
        var list = [1, 2, 3, 4, 5]

        list = notificationHelper.removeElement(2, from: list)
        XCTAssertEqual([1, 3, 4, 5], list)

        list = notificationHelper.removeElement(1, from: list)
        XCTAssertEqual([3, 4, 5], list)

        list = notificationHelper.removeElement(5, from: list)
        XCTAssertEqual([3, 4], list)

        list = notificationHelper.removeElement(3, from: list)
        XCTAssertEqual([4], list)

        list = notificationHelper.removeElement(4, from: list)
        XCTAssertEqual([], list)

        list = notificationHelper.removeElement(4, from: list)
        XCTAssertEqual([], list)
    }

    func testGetComponentsFromDate() {
        let string = "20:32 Wed, 30 Oct 2019"
        let formatter4 = DateFormatter()
        formatter4.dateFormat = "HH:mm E, d MMM y"
        let date = formatter4.date(from: string)!

        let components = notificationHelper.getComponentsFromDate(date)

        XCTAssertEqual(2019, components.year)
        XCTAssertEqual(10, components.month)
        XCTAssertEqual(30, components.day)
        XCTAssertEqual(20, components.hour)
        XCTAssertEqual(32, components.minute)
        XCTAssertEqual(nil, components.second)
    }

    func testGetCurrentDate() {
        let today = notificationHelper.getComponentsFromDate(Date())

        let date = notificationHelper.getCurrentDate(hour: 9, minutes: 30)

        XCTAssertEqual(today.day, date.day)
        XCTAssertEqual(today.year, date.year)
        XCTAssertEqual(today.month, date.month)
        XCTAssertEqual(today.day, date.day)
        XCTAssertEqual(9, date.hour)
        XCTAssertEqual(30, date.minute)
        XCTAssertEqual(0, date.second)
    }

    func testScheduleAllNotifications() {
        let activity = Activity(
            id: 0,
            name: "Run",
            minValue: 0,
            maxValue: 10,
            total: 10,
            isEnabled: true)

        let activities = [activity]

        let defaults = UserDefaults()

        defaults.setValue(3, forKey: "DaysPerWeek")

        notificationHelper.scheduleAllNotifications(activities: activities)

        XCTAssertEqual(3, notificationHelper.numberOfNotificationsScheduled)
    }

    class TestNotificationHelper: NotificationHelper {
        var numberOfNotificationsScheduled = 0

        override func scheduleNotification(title: String, body: String, dateTime: DateComponents) {
            numberOfNotificationsScheduled += 1
        }

        override func isAuthorizedToSendNotifications() -> Bool {
            return true
        }
    }
}
