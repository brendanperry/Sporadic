//
//  ActivityViewModelTests.swift
//  SporadicTests
//
//  Created by Brendan Perry on 6/30/21.
//

import XCTest
@testable import Sporadic

class ActivityViewModelTests: XCTestCase {
    var vm = TestActivityViewModel()

    override func tearDownWithError() throws {
        vm.resetDefaults()
    }
    
    // we may want to put these tests in local data helper tests because it was pulled out
    
    func testActivitiesAreAtDefaultValuesWhenNothingIsStoredOnDevice() throws {
        let initializedActivities = vm.getInitializeActivities()
        let loadedActivities = vm.getLoadedActivities(activities: initializedActivities)
        
        XCTAssertEqual(initializedActivities, loadedActivities)
     }
    
    // IMPORTANT TO FIX
    
//    func testWrittenDataIsLoadedFromDevice() throws {
//        let initializedActivities = vm.getInitializeActivities()
//        let currentActivities = vm.getLoadedActivities(activities: initializedActivities)
//
//        let newRun = Activity(id: 3, unit: Unit.MilesOrKilometers, name: "Test1", minValue: 14, maxValue: 26.2, total: 0, isEnabled: true)
//        let newBike = Activity(id: 3, unit: Unit.MilesOrKilometers, name: "Test2", minValue: 13, maxValue: 10, total: 10, isEnabled: true)
//
//        let newActivities = [newRun, newBike]
//
//        vm.saveActivities(activities: newActivities)
//
//        let loadedActivities = vm.getLoadedActivities(activities: currentActivities)
//
//        XCTAssertEqual(newActivities, loadedActivities)
//    }
     
     class TestActivityViewModel: ActivityViewModel {
         override func getInitializeActivities() -> [Activity] {
            var initializedActivityList = [Activity]()
             
            let run = Activity(id: 0, unit: Unit.MilesOrKilometers, name: "Test1", minValue: 0.1, maxValue: 26.2, total: 0, isEnabled: true)
             
            let bike = Activity(id: 1, unit: Unit.Minutes, name: "Test2", minValue: 0.1, maxValue: 50, total: 0, isEnabled: false)
             
            initializedActivityList.append(run)
            initializedActivityList.append(bike)
             
            return initializedActivityList
         }
        
        func resetDefaults() {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        }
     }
}
