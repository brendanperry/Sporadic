////
////  EditActivityViewModel.swift
////  Sporadic
////
////  Created by Brendan Perry on 1/20/22.
////
//
//import Foundation
//import CoreData
//
//class EditActivityViewModel : ObservableObject {
//    let activityTemplateHelper: ActivityTemplateHelper
//    let notificationHelper: NotificationHelper
//    let activity: Activity
//    let activityTemplate: ActivityTemplate
//    let dataHelper: Repository
//    
//    @Published var minValue = 0.0
//    @Published var maxValue = 0.0
//    @Published var isEnabled = false
//    
//    init(
//        activity: Activity,
//        activityTemplateHelper: ActivityTemplateHelper,
//        notificationHelper: NotificationHelper,
//        dataHelper: Repository
//    ) {
//        self.activityTemplateHelper = activityTemplateHelper
//        self.notificationHelper = notificationHelper
//        self.activity = activity
//        self.dataHelper = dataHelper
//        
////        activityTemplate = activityTemplateHelper.getActivityTemplateById(id: activity.activityTemplateId)
//        
////        initializeActivity()
//    }
//    
//    func initializeActivity() {
//        if isActivityNew(activity: activity) {
////            activity.minValue = activityTemplate.minValue
////            activity.maxValue = activityTemplate.maxValue
////            activity.minRange = activityTemplate.minRange
//        }
//        
////        isEnabled = activity.isEnabled
////        minValue = activity.minValue
////        maxValue = activity.maxValue
//    }
//    
//    func isActivityNew(activity: Activity) -> Bool {
//        let activityDefaultMaxValue = 0.0
//        
////        return activity.maxValue == activityDefaultMaxValue
//    }
//    
//    func saveActivity() {
//        DispatchQueue.main.async { [weak self] in
////            self?.activity.isEnabled = self?.isEnabled ?? false
////            self?.activity.minValue = self?.minValue ?? 0
////            self?.activity.maxValue = self?.maxValue ?? 0
//            
//            self?.notificationHelper.scheduleAllNotifications(settingsChanged: true)
//        }
//    }
//}
