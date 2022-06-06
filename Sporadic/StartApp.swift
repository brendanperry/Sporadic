//
//  GCMiApp.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import OneSignal
import CloudKit

@main
struct StartApp: App {
    //let dataController = DataController.shared
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
                MainView()
                //.environment(\.managedObjectContext, dataController.container.viewContext)
//                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
//                    dataController.saveChanges()
//                })
        }
//        .onChange(of: scenePhase) { _ in
//            dataController.saveChanges()
//        }
    }
}

/// async gets iCloud record ID object of logged-in iCloud user
func iCloudUserIDAsync(complete: @escaping (_ instance: CKRecord.ID?, _ error: NSError?) -> ()) {
    let container = CKContainer.default()
    container.fetchUserRecordID() {
        recordID, error in
        if error != nil {
            print(error!.localizedDescription)
            complete(nil, error as NSError?)
        } else {
            print("fetched ID \(recordID?.recordName)")
            complete(recordID, nil)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().isHidden = true
        
        iCloudUserIDAsync { (recordID: CKRecord.ID?, error: NSError?) in
            if let userID = recordID?.recordName {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(userID, forKey: UserPrefs.userId.rawValue)
                    
                    // Remove this method to stop OneSignal Debugging
                    OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
                    OneSignal.initWithLaunchOptions(launchOptions)
                    OneSignal.setAppId("f211cce4-760d-4404-97f3-34df31eccde8")
                     
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        print("User accepted notification: \(accepted)")
                        OneSignal.setExternalUserId(userID)
                    })
                }
            } else {
                DispatchQueue.main.async {
                    print("Fetched iCloudID was nil")
                    let userId = "local_\(UUID())"
                    UserDefaults.standard.set(userId, forKey: UserPrefs.userId.rawValue)
                    
                    // Remove this method to stop OneSignal Debugging
                    OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
                    OneSignal.initWithLaunchOptions(launchOptions)
                    OneSignal.setAppId("f211cce4-760d-4404-97f3-34df31eccde8")
                     
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        print("User accepted notification: \(accepted)")
                        OneSignal.setExternalUserId(userId)
                    })
                }
            }
        }
      
       return true
    }
}
