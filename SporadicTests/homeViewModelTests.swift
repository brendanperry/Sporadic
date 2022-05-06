//
//  homeViewModelTests.swift
//  SporadicTests
//
//  Created by Brendan Perry on 3/12/22.
//

import XCTest
import CoreData
@testable import Sporadic

class homeViewModelTests: XCTestCase {
    var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "MM/dd/YYYY hh:mm a"
        return formatter
    }()
    
    func testGetChallengesOnLoad() {
        let dataHelperMock = DataHelperMock(date: Date())
        let _ = HomeViewModel(dataHelper: dataHelperMock)
        
        XCTAssertTrue(dataHelperMock.wasFetchChallengesCalled)
    }

    func testShowTodayChallengeOnHomeScreen() {
        let dataHelperMock = DataHelperMock(date: Date())
        let homeViewModel = HomeViewModel(dataHelper: dataHelperMock)
        
        let challenge = homeViewModel.getDailyActivity()
        
        XCTAssertTrue(challenge?.total == 10)
    }
    
    func testGivenChallengeAtStartOfDayShowsOnHomeScreen() {
        let dataHelperMock = DataHelperMock(date: getStartOfDay())
        let homeViewModel = HomeViewModel(dataHelper: dataHelperMock)
        
        let challenge = homeViewModel.getDailyActivity()
        
        XCTAssertTrue(challenge?.total == 10)
    }
    
    func testGivenChallengeAtEndOfDayShowsOnHomeScreen() {
        let dataHelperMock = DataHelperMock(date: getEndOfDay())
        let homeViewModel = HomeViewModel(dataHelper: dataHelperMock)
        
        let challenge = homeViewModel.getDailyActivity()
        
        XCTAssertTrue(challenge?.total == 10)
    }
    
    func testGivenChallengeAtEndOfDayUTCShowsOnHomeScreen() {
        let dataHelperMock = DataHelperMock(date: getEndOfDayUTC())
        let homeViewModel = HomeViewModel(dataHelper: dataHelperMock)
        
        let challenge = homeViewModel.getDailyActivity()
        
        XCTAssertTrue(challenge?.total == 10)
    }
    
    func testGivenChallengeAtStartOfDayUTCShowsOnHomeScreen() {
        let dataHelperMock = DataHelperMock(date: getStartOfDayUTC())
        let homeViewModel = HomeViewModel(dataHelper: dataHelperMock)
        
        let challenge = homeViewModel.getDailyActivity()
        
        XCTAssertTrue(challenge?.total == 10)
    }
    
    func getStartOfDay() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 0
        components.minute = 00
        components.second = 00
        components.timeZone = TimeZone.current
            
        return Calendar.current.date(from: components)!
    }
    
    func getStartOfDayUTC() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 4
        components.minute = 00
        components.second = 00
        components.timeZone = TimeZone(identifier: "UTC")
            
        return Calendar.current.date(from: components)!
    }
                                    
    func getEndOfDay() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 23
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone.current
        
        return Calendar.current.date(from: components)!
    }
    
    func getEndOfDayUTC() -> Date {
        var components = getComponentsFromDate(Date())

        components.hour = 3
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone(identifier: "UTC")
        
        let time = Calendar.current.date(from: components)!
        
        return Calendar.current.date(byAdding: .day, value: 1, to: time)!
    }
}

class DataHelperMock: Repository {
    var challenges = [Challenge]()
    var activities = [Activity]()
    let date: Date
    
    var wasSaveCalled = false
    var wasFetchChallengesCalled = false
    var wasRemovePendingChallengesCalled = false
    var shouldCountAddedChallenges = false
    var addedChallengesCount = 0
    
    let context = DataController.shared.controller.viewContext
    
    init(date: Date) {
        self.date = date
        let activity = Activity(context: context)
        createChallenge(amount: 10.0, time: date, isCompleted: false, activity: activity)
    }
    
    func createChallenge(amount: Double, time: Date, isCompleted: Bool, activity: Activity) {
        let createdChallenge: Challenge = Challenge(context: context)
        createdChallenge.total = amount
        createdChallenge.time = time
        createdChallenge.isCompleted = isCompleted
        createdChallenge.oneChallengeToOneActivity = activity
        
        challenges.append(createdChallenge)
        
        if shouldCountAddedChallenges {
            addedChallengesCount += 1
        }
    }
    
    func createActivity() -> Activity {
        let createdActivity: Activity = Activity(context: context)
        createdActivity.isEnabled = true
        
        activities.append(createdActivity)
        
        return createdActivity
    }
    
    func fetchChallenges() -> [Challenge]? {
        wasFetchChallengesCalled = true
        return challenges
    }
    
    func fetchActivities() -> [Activity]? {
        return activities
    }
    
    func saveChanges() {
        wasSaveCalled = true
    }
    
    func fetchActiveActivities() -> [Activity]? {
        return activities.filter({ $0.isEnabled })
    }
    
    func getTotalChallengesScheduled() -> Int {
        return challenges.filter({ ($0.time ?? Date()) > getEndOfDay() }).count
    }
    
    func removeAllPendingChallenges() {
        wasRemovePendingChallengesCalled = true
    }
    
    func fetchCurrentChallenge() -> Challenge? {
        return challenges.first(where: { getComponentsFromDate($0.time ?? Date()).day ==  getComponentsFromDate(Date()).day})
    }

    func popLastScheduledChallenge() -> Date? {
        let lastChallenge = challenges.sorted(by: { ($0.time ?? Date()) > ($1.time ?? Date()) }).first
        
        if let challenge = lastChallenge {
            let time = lastChallenge?.time
            challenges.remove(at: challenges.firstIndex(of: challenge) ?? 0)
            return time
        }
        
        return nil
    }
}

func getComponentsFromDate(_ date: Date) -> DateComponents {
    let requestedComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
    
    return Calendar.current.dateComponents(requestedComponents, from: date)
}

func getStartOfDay() -> Date {
    var components = getComponentsFromDate(Date())
    
    components.hour = 0
    components.minute = 00
    components.second = 00
    components.timeZone = TimeZone.current
    
    return Calendar.current.date(from: components)!
}

func getEndOfDay() -> Date {
    var components = getComponentsFromDate(Date())
    
    components.hour = 23
    components.minute = 59
    components.second = 59
    components.timeZone = TimeZone.current
    
    return Calendar.current.date(from: components)!
}
