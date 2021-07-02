//
//  SporadicTests.swift
//  SporadicTests
//
//  Created by Brendan Perry on 6/30/21.
//

import XCTest
@testable import Sporadic

class SporadicTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssert(1 == 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func newTest() throws {
         let vm = TestActivityViewModel()
     
         let initializedActivities = vm.activities
     
         vm.activities = vm.getInitializeActivities()
         XCTAssertEqual(1, 2)
         XCTAssertEqual(initializedActivities, vm.activities)
     }
     
     class TestActivityViewModel: ActivityViewModel {
         override func getInitializeActivities() -> [Activity] {
             var initializedActivityList = [Activity]()
             
            let run = Activity(id: 0, unit: Unit.MilesOrKilometers, name: "Test1", minValue: 0.1, maxValue: 26.2, total: 0, isEnabled: true)
             
            let bike = Activity(id: 1, unit: Unit.Minutes, name: "Test2", minValue: 0.1, maxValue: 50, total: 0, isEnabled: false)
             
             initializedActivityList.append(run)
             initializedActivityList.append(bike)
             
             return initializedActivityList
         }
     }

}
