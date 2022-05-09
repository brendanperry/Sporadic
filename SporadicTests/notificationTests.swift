//
//  notificationTests.swift
//  SporadicTests
//
//  Created by Brendan Perry on 4/21/22.
//

import XCTest
import CoreData
@testable import Sporadic

// need to mock out notification status

class notificationTests: XCTestCase {

    func testGivenSettingsChangedThenNotifcationsAreCleared() {
        let dataMock = DataHelperMock(date: Date())
        let helper = NotificationHelper(dataHelper: dataMock)
        
        helper.scheduleAllNotifications(settingsChanged: true)
        
        XCTAssert(dataMock.wasRemovePendingChallengesCalled == true)
    }
    
    func testGivenSettingsNotChangedThenNotifcationsAreNotCleared() {
        let dataMock = DataHelperMock(date: Date())
        let helper = NotificationHelper(dataHelper: dataMock)
        
        helper.scheduleAllNotifications(settingsChanged: false)
        
        XCTAssert(dataMock.wasRemovePendingChallengesCalled == false)
    }
    
    func testGivenNoActivitiesActiveThenNoChallengesAdded() {
        let dataMock = DataHelperMock(date: Date())
        let helper = NotificationHelper(dataHelper: dataMock)
        
        helper.scheduleAllNotifications(settingsChanged: false)
        
        XCTAssert(dataMock.challenges.count == 0)
    }
    
    func testGivenNoNotificationsThen84Scheduled() {
        let dataMock = DataHelperMock(date: Date())
        let helper = NotificationHelper(dataHelper: dataMock)
        
        UserDefaults.standard.set(7, forKey: UserPrefs.daysPerWeek.rawValue)
        
        let _ = dataMock.createActivity()
        
        helper.scheduleAllNotifications(settingsChanged: true)
        
        print("CHALLENGES: \(dataMock.challenges.count)")
        XCTAssert(dataMock.challenges.count == 84)
    }
    
    func testUserComesBackToAppWithChallengesDepletedThenChallengesRefilled() {
        let dataMock = DataHelperMock(date: Date())
        let helper = NotificationHelper(dataHelper: dataMock)
        
        UserDefaults.standard.set(7, forKey: UserPrefs.daysPerWeek.rawValue)
        
        let activity = dataMock.createActivity()
        dataMock.createChallenge(amount: 20, time: Date(), isCompleted: false, activity: activity)
        
        dataMock.shouldCountAddedChallenges = true
        
        helper.scheduleAllNotifications(settingsChanged: false)
        
        print("CHALLENGES: \(dataMock.challenges.count)")
        XCTAssert(dataMock.challenges.count == 84)
        XCTAssert(dataMock.addedChallengesCount == 83)
    }
    
    func testUserComesBackToAppWithChallengesFullyDepletedThenChallengesRefilled() {
        let dataMock = DataHelperMock(date: Date())
        let helper = NotificationHelper(dataHelper: dataMock)
        
        UserDefaults.standard.set(7, forKey: UserPrefs.daysPerWeek.rawValue)
        
        let _ = dataMock.createActivity()
        
        dataMock.shouldCountAddedChallenges = true
        
        helper.scheduleAllNotifications(settingsChanged: false)
        
        print("CHALLENGES: \(dataMock.challenges.count)")
        XCTAssert(dataMock.challenges.count == 84)
        XCTAssert(dataMock.addedChallengesCount == 84)
    }
}
