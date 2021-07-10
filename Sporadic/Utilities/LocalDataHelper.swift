//
//  LocalDataHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/1/21.
//

import Foundation

class LocalDataHelper {
    let defaults = UserDefaults.standard
    
    // this doesn't seem to work for different types - defaults.integer
    
    public func get<T: Codable>(defaultValue: T, key: String) -> T {
        do {
            if let savedData = defaults.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                
                let loadedData = try decoder.decode(T.self, from: savedData)
                
                return loadedData;
            }
        } catch {
            print("Could not load activity from device.")
        }
        
        return defaultValue
    }
    
    public func save<T: Codable>(data: T, key: String) -> T {
        do {
            let encoder = JSONEncoder()
            
            let encodedActivity = try encoder.encode(data);
            
            defaults.set(encodedActivity, forKey: key)
        } catch {
            print("Could not save to device.")
        }
        
        return data
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
}
