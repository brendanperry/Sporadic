//
//  GCMiApp.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import OneSignalFramework


@main
struct StartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(storeManager)
                .alert("Version", isPresented: $storeManager.showVersion) {
                    Button("Close") {
                        storeManager.showVersion = false
                    }
                } message: {
                    Text(storeManager.version)
                }

        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().isHidden = true
        
        OneSignal.Debug.setLogLevel(.LL_NONE)
        OneSignal.initialize("f211cce4-760d-4404-97f3-34df31eccde8", withLaunchOptions: launchOptions)
        
        return true
    }
}
