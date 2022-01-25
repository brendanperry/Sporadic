//
//  HomeViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation
import CoreData

class HomeViewModel : ObservableObject {
    let context: NSManagedObjectContext
    
    @Published var challenge: Challenge?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        challenge = getDailyActivity()
    }
    
    func saveChallenge() {
        try? context.save()
    }
    
    func getDailyActivity() -> Challenge? {
        let fetchRequest = Challenge.fetchRequest()
        
        let startOfDay = getStartOfDay()
        let endOfDay = getEndOfDay()
        
        //fetchRequest.predicate = NSPredicate(format: "(time >= %@) AND (time <= %@)", startOfDay, endOfDay)
        
        let challenges = try? context.fetch(fetchRequest)
        
        if challenges == nil || challenges?.count == 0 {
            return nil
        }
        
        let challenge = getChallengeWithinDateRange(startDate: startOfDay, endDate: endOfDay, challenges: challenges!)
        
        if let challenge = challenge {
            return challenge
        } else {
            return nil
        }
    }
    
    func getChallengeWithinDateRange(startDate: Date, endDate: Date, challenges: [Challenge]) -> Challenge? {
        for challenge in challenges {
            if var date = challenge.time {
                date = utcToLocal(date: date)
                
                if date > startDate && date < endDate {
                    return challenge
                }
            }
        }
        
        return nil
    }
    
    func utcToLocal(date: Date) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: dateFormatter.string(from: date))!
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

    internal func getComponentsFromDate(_ date: Date) -> DateComponents {
        let requestedComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]

        return Calendar.current.dateComponents(requestedComponents, from: date)
    }
}
