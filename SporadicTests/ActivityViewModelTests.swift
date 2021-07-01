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

    func testActivitiesAreAtDefaultValuesWhenNothingIsStoredOnDevice() throws {
        let initializedActivities = vm.getInitializeActivities()
        let loadedActivities = vm.getLoadedActivities(activities: initializedActivities)
        
        XCTAssertEqual(initializedActivities, loadedActivities)
     }
    
    func testSavingAndLoadingDataFromDevice() throws {
        let id = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e") ?? UUID()
         
        let saveTest = Activity(id: id, unit: Unit.MilesOrKilometers, name: "SaveTest", minValue: 0.1, maxValue: 26.2, total: 0, isEnabled: true)
        
        let saveOverride = Activity(id: id, unit: Unit.MilesOrKilometers, name: "SaveTest", minValue: 10, maxValue: 10, total: 10, isEnabled: false)
        
        vm.saveDataToDevice(activity: saveTest)
        
        let loadedActivity = vm.getDataFromDevice(activity: saveOverride)
        
        XCTAssertEqual(saveTest, loadedActivity)
    }
     
     class TestActivityViewModel: ActivityViewModel {
         override func getInitializeActivities() -> [Activity] {
            var initializedActivityList = [Activity]()
            
            let id = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e") ?? UUID()
             
            let run = Activity(id: id, unit: Unit.MilesOrKilometers, name: "Test1", minValue: 0.1, maxValue: 26.2, total: 0, isEnabled: true)
             
            let bike = Activity(id: id, unit: Unit.Minutes, name: "Test2", minValue: 0.1, maxValue: 50, total: 0, isEnabled: false)
             
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
