//
//  ActivityTemplateHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation
import SwiftUI
import CoreData

class ActivityTemplateHelper {
    func getActivityTemplates() -> [ActivityTemplate] {
        let run = ActivityTemplate(id: 1, name: "Run", minValue: 0.25, maxValue: 20.0, selectedMin: 1.0, selectedMax: 3.0, minRange: 0.25, unit: .miles)
        
        let bike = ActivityTemplate(id: 2, name: "Bike", minValue: 0.5, maxValue: 30.0, selectedMin: 2.0, selectedMax: 4.0, minRange: 0.5, unit: .miles)
        
        let yoga = ActivityTemplate(id: 3, name: "Yoga", minValue: 5, maxValue: 120, selectedMin: 10, selectedMax: 30, minRange: 1, unit: .minutes)
        
        let swim = ActivityTemplate(id: 4, name: "Swim", minValue: 5, maxValue: 120, selectedMin: 10, selectedMax: 30, minRange: 1, unit: .minutes)
        
        let dance = ActivityTemplate(id: 5, name: "Dance", minValue: 5, maxValue: 120, selectedMin: 10, selectedMax: 30, minRange: 1, unit: .minutes)
        
        let sports = ActivityTemplate(id: 6, name: "Sports", minValue: 30, maxValue: 120, selectedMin: 30, selectedMax: 60, minRange: 1, unit: .minutes)
        
        let hike = ActivityTemplate(id: 7, name: "Hike", minValue: 30, maxValue: 240, selectedMin: 60, selectedMax: 120, minRange: 1, unit: .minutes)
        
        let paddle = ActivityTemplate(id: 8, name: "Paddle", minValue: 30, maxValue: 120, selectedMin: 30, selectedMax: 120, minRange: 1, unit: .minutes)
        
        return [run, bike, yoga, swim, dance, sports, hike, paddle]
    }
}
