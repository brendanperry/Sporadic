//
//  ActivityTemplateHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation
import SwiftUI
import CoreData

public class ActivityTemplateHelper {
    static var templates = [
        ActivityTemplate(id: 1, name: "Run", minValue: 0.25, maxValue: 20.0, selectedMin: 1.0, selectedMax: 3.0, minRange: 0.25, unit: .miles, category: .cardio, requiresEquipment: false, canDoIndoors: false),
        
        ActivityTemplate(id: 2, name: "Bike", minValue: 0.5, maxValue: 30.0, selectedMin: 2.0, selectedMax: 4.0, minRange: 0.5, unit: .miles, category: .cardio, requiresEquipment: true, canDoIndoors: false),
        
        ActivityTemplate(id: 3, name: "Yoga", minValue: 5, maxValue: 120, selectedMin: 10, selectedMax: 30, minRange: 1, unit: .minutes, category: .strength, requiresEquipment: true, canDoIndoors: false),
        
        ActivityTemplate(id: 4, name: "Swim", minValue: 5, maxValue: 120, selectedMin: 10, selectedMax: 30, minRange: 1, unit: .minutes, category: .cardio, requiresEquipment: true, canDoIndoors: false),
        
        ActivityTemplate(id: 5, name: "Walk", minValue: 0.25, maxValue: 20.0, selectedMin: 0.5, selectedMax: 2, minRange: 0.25, unit: .miles, category: .cardio, requiresEquipment: false, canDoIndoors: false),
        
        ActivityTemplate(id: 6, name: "Burpees", minValue: 5, maxValue: 100.0, selectedMin: 10, selectedMax: 20, minRange: 1, unit: .reps, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 7, name: "Crunches", minValue: 5, maxValue: 100, selectedMin: 10, selectedMax: 25, minRange: 1, unit: .reps, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 8, name: "Jumping Jacks", minValue: 5, maxValue: 100, selectedMin: 10, selectedMax: 25, minRange: 1, unit: .reps, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 9, name: "Lunges", minValue: 6, maxValue: 100, selectedMin: 10, selectedMax: 24, minRange: 2, unit: .reps, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 10, name: "Plank", minValue: 10, maxValue: 180, selectedMin: 30, selectedMax: 60, minRange: 1, unit: .seconds, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 11, name: "Pull-ups", minValue: 1, maxValue: 25, selectedMin: 5, selectedMax: 10, minRange: 1, unit: .reps, category: .strength, requiresEquipment: true, canDoIndoors: true),
        
        ActivityTemplate(id: 12, name: "Squats", minValue: 5, maxValue: 50, selectedMin: 10, selectedMax: 25, minRange: 1, unit: .reps, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 13, name: "Push-ups", minValue: 5, maxValue: 100, selectedMin: 10, selectedMax: 25, minRange: 1, unit: .reps, category: .strength, requiresEquipment: false, canDoIndoors: true),
        
        ActivityTemplate(id: 14, name: "Wall Sit", minValue: 15, maxValue: 180, selectedMin: 30, selectedMax: 60, minRange: 1, unit: .seconds, category: .strength, requiresEquipment: false, canDoIndoors: true)
    ]
    
    static func getTemplate(by id: Int) -> ActivityTemplate? {
        return templates.first(where: { $0.id == id })
    }
}
