//
//  MainView.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var activityViewModel = ActivityViewModel()
    @StateObject var viewRouter = ViewRouter()
    
    @State var selectedTab = 0
    @State var isAdding = false
    
    @AppStorage(UserPrefs.appearance.rawValue)
    var appTheme = "System"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                switch viewRouter.currentPage {
                case .home:
                    HomePage()
                        .blur(radius: isAdding ? 100 : 0)
                case .settings:
                    SettingsPage()
                        .blur(radius: isAdding ? 100 : 0)
                case .tutorial:
                    Text("Tutorial")
                }
                
                AddPage(isAdding: self.isAdding, topSafeArea: geometry.safeAreaInsets.top)
                
                NavigationBar(isAdding: self.$isAdding)
            }
            .environmentObject(activityViewModel)
            .environmentObject(viewRouter)
            .preferredColorScheme(self.getColorSceme())
        }
    }

    func getColorSceme() -> ColorScheme? {
        if appTheme == "Light" {
            return .light
        }

        if appTheme == "Dark" {
            return .dark
        }

        return nil
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
