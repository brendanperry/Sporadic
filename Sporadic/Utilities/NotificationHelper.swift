//
//  NotificationHelper.swift
//  Sporadic
//
//  Created by brendan on 3/10/24.
//

import Foundation

public struct NotificationData: Encodable {
    let app_id: String
    let include_subscription_ids: [String]
    let contents: [String: String]
    let headings: [String: String]
}

struct NotificationHelper {
    
    func postNotification(data: NotificationData) async {
        guard let data = try? JSONEncoder().encode(data) else { return }
        guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
        guard let path = Bundle.main.path(forResource: "onesignal-key", ofType: "txt") else { return }
        guard let key = try? String(contentsOfFile: path) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(key.trimmingCharacters(in: [" ", "\n"]), forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let wow = try? await URLSession.shared.data(for: request)
        
        print(wow?.0)
        print(wow?.1)
    }
}
