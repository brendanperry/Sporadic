//
//  MainView.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var activityViewModel = ActivityViewModel()
    @State var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomePage()
                    .onTapGesture {
                        selectedTab = 0
                    }
                    .tabItem {
                        Image(systemName: "house")
                    }
                    .tag(0)
                SettingsPage()
                    .onTapGesture {
                        selectedTab = 1
                    }
                    .tabItem {
                        Image(systemName: "gear")
                    }
                    .tag(1)
            }
            .onChange(of: selectedTab) { newValue in
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
            .environmentObject(activityViewModel)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
