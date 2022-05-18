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
        let app_id = "f211cce4-760d-4404-97f3-34df31eccde8"
        let contents: [String: String]
        let heading = ["en": "New Challenge"]
        let include_external_user_ids: [String]
        let channel_for_external_user_ids = "push"
        let send_after: String
        let delayed_option = "timezone"
        let delivery_time_of_day: String
    }
    
    struct DeleteParams: Encodable {
        let id: String
        let app_id = "f211cce4-760d-4404-97f3-34df31eccde8"
    }
    
    func postNotification(body: String, sendAfter: String, time: String, completion: @escaping(String?) -> Void) async throws {
        let params = NotificationParams(
            contents: ["en": "\(body)"],
            include_external_user_ids: ["\(UserDefaults.standard.string(forKey: UserPrefs.userId.rawValue) ?? "")"],
            send_after: sendAfter,
            delivery_time_of_day: time)
        
        AF.request("https://onesignal.com/api/v1/notifications").response { response in
            print(response)
        }
        
        let dataTask = AF.request("https://onesignal.com/api/v1/notifications",
                                  method: .post,
                                  parameters: params,
                                  encoder: .json,
                                  headers: .init([.authorization("Basic Zjg3NGE1MTItOWRkNy00NmY5LTgzNzEtMjZlNDU4YmMyMzk1"), .accept("application/json")]),
                                  interceptor: nil,
                                  requestModifier: nil).serializingData()
        
        let result = await dataTask.response.result
        
        switch result {
        case .success(let result):
            do{
                if let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String : Any] {
                    if let id = json["id"] {
                        print(String(describing: id))
                    }
                    
                    if let errors = json["errors"] {
                        throw NSError(domain: String(describing: errors), code: 0)
                    }
                }
            } catch {
                print(error)
            }
        case .failure(let error):
            print(error)
        }
        
        print("Schedule failed with unknown error.")
    }
    
    func cancelNotification(notificationId: String) {
        let params = DeleteParams(id: notificationId)
        
        AF.request("https://onesignal.com/api/v1/notifications/:id?app_id=:app_id",
                   method: .delete,
                   parameters: params,
                   encoder: .json,
                   headers: [.authorization("Basic Zjg3NGE1MTItOWRkNy00NmY5LTgzNzEtMjZlNDU4YmMyMzk1")],
                   interceptor: nil,
                   requestModifier: nil).response { response in
            print(response)
        }
    }
}
