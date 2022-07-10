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
        let run = ActivityTemplate(id: 1, name: "Run", minValue: 0.25, maxValue: 20.0, selectedMin: 1.0, selectedMax: 3.0, minRange: 0.25, unit: "mi")
        
        let bike = ActivityTemplate(id: 2, name: "Bike", minValue: 0.5, maxValue: 30.0, selectedMin: 2.0, selectedMax: 4.0, minRange: 0.5, unit: "mi")
        
        let yoga = ActivityTemplate(id: 3, name: "Yoga", minValue: 5, maxValue: 120, selectedMin: 10, selectedMax: 30, minRange: 1, unit: "min")
        
        return [run, bike, yoga]
    }
    
    func getActivityTemplateById(id: Int16) -> ActivityTemplate {
        let activityTemplates = getActivityTemplates()
        
        return activityTemplates.first(where: { $0.id == id })!
    }
    
    func getActivityTemplatesByActivities(activities: [Activity]) -> [ActivityTemplate] {
        var templates = [ActivityTemplate]()
        
        for activity in activities {
//            templates.append(getActivityTemplateById(id: activity.activityTemplateId))
        }
        
        return templates
    }
    
//    func getActivityTemplatesToAdd(enabledActivities: FetchedResults<Activity>) -> [ActivityTemplate] {
//        var activityTemplatesToAdd = [ActivityTemplate]()
//        let activityTemplates = getActivityTemplates()
//        
//        for template in activityTemplates {
//            if !enabledActivities.contains(where: { $0.activityTemplateId == template.id }) {
//                activityTemplatesToAdd.append(template)
//            }
//        }
//        
//        return activityTemplatesToAdd
//    }
    
    func getAndCreateDefaultActivities() -> [Activity] {
        var activities = [Activity]()
        let templates = getActivityTemplates()
        
        for template in templates {
//            activities.append(createNewActivity(activityTemplate: template))
        }
        
        return activities
    }
    
    // pull out into activity helper maybe
//    func getActivity(activityTemplate: ActivityTemplate) -> Activity {
//        let context = DataController.shared.container.viewContext
//        let fetchRequest = Activity.fetchRequest()
//
//        fetchRequest.predicate = NSPredicate(format: "activityTemplateId == %i", activityTemplate.id)
//
//        let activity = try? context.fetch(fetchRequest).first
//
//        if let activity = activity {
//            return activity
//        } else {
//            return createNewActivity(activityTemplate: activityTemplate)
//        }
//    }
    
//    func createNewActivity(activityTemplate: ActivityTemplate) -> Activity {
//        let context = DataController.shared.container.viewContext
//        let activity = Activity(context: context)
//        activity.activityTemplateId = activityTemplate.id
//        activity.name = activityTemplate.name
//        activity.minValue = activityTemplate.selectedMin
//        activity.maxValue = activityTemplate.selectedMax
//        activity.isEnabled = false
//        activity.total = 0
//        activity.unit = activityTemplate.unit
//        activity.minRange = activityTemplate.minRange
//        
//        return activity
//    }
}
