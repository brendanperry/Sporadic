//
//  OneSignalHelper.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/15/22.
//

import Foundation
import OneSignal
import Alamofire

struct OneSignalHelper {
    struct NotificationParams: Encodable {
        let notificationIdsToCancel: [String]
        let notificationsToSchedule: [NotificationTemplate]
    }
    
    struct NotificationTemplate: Encodable {
        let users: [String]
        let title: String
        let subtitle: String
        let message: String
        let date: String
    }
    
    struct DeleteParams: Encodable {
        let id: String
        let app_id = "f211cce4-760d-4404-97f3-34df31eccde8"
    }
    
    struct ResponseObject: Codable {
        let ids: [String]
    }
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
        return dateFormatter
    }()
    
    func postNotification(cancelledNotificationIds: [String], challenges: [Challenge], completion: @escaping([String]) -> Void) {
        // update this for groups
//        let notificationsToSchedule = challenges.map {
//            NotificationTemplate(
//                users: [UserDefaults.standard.string(forKey: UserPrefs.userId.rawValue) ?? ""],
//                title: "New challenge",
//                subtitle: "",
//                message: "\($0.activity?.name ?? "") \($0.amount) \($0.activity?.unit ?? "")",
//                date: dateFormatter.string(from: $0.startTime ?? Date()))
//        }
        
//        let params = NotificationParams(notificationIdsToCancel: cancelledNotificationIds, notificationsToSchedule: notificationsToSchedule)
//        
//        AF.request("https://echv52sz7o6l45jjjevlpfcczu0uxxml.lambda-url.us-east-2.on.aws/",
//                                  method: .post,
//                                  parameters: params,
//                                  encoder: .json,
//                                  headers: .init([.accept("application/json")]),
//                                  interceptor: nil,
//                                  requestModifier: nil).responseDecodable(of: ResponseObject.self, queue: .main) { response in
//            switch response.result {
//            case .success(let object):
//                completion(object.ids)
//            case .failure(let error):
//                print(error)
//                completion([])
//            }
//        }
    }
}
