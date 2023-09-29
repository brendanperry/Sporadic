//
//  GCMiApp.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import OneSignal


@main
struct StartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().isHidden = true
        
        OneSignal.setLogLevel(.LL_ERROR, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setLocationShared(false)
        OneSignal.setAppId("f211cce4-760d-4404-97f3-34df31eccde8")
        
        return true
    }
}
