//
//  HealthKitHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/17/22.
//

import Foundation
import HealthKit

class HealthKitHelper {
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((_ success: Bool) -> Void)!) {
        let writableTypes: Set<HKSampleType> = []
        let readableTypes: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!, HKWorkoutType.workoutType()]

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        healthStore.requestAuthorization(toShare: writableTypes, read: readableTypes) { (success, error) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getSamples(for workoutType: HKWorkoutActivityType, completion: @escaping ([HKWorkout]?, Error?) -> Swift.Void) {
        let predicate = HKQuery.predicateForWorkouts(with: workoutType)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                          ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(),
                                    predicate: predicate,
                                    limit: HKObjectQueryNoLimit,
                                    sortDescriptors: [sortDescriptor]) { (query, samples, error) in
        
            DispatchQueue.main.async {
                
            guard let samples = samples as? [HKWorkout] else {
                completion(nil, error)
                return
            }
                
            completion(samples, nil)
            }
        }
     
        healthStore.execute(sampleQuery)
    }
}
 
