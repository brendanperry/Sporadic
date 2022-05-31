//
//  MainView.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewRouter = ViewRouter()
    @State var selectedTab = 0
    @State var isAdding = false
    
    @AppStorage(UserPrefs.appearance.rawValue)
    var appTheme = "System"
    
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var activities: FetchedResults<Activity>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                switch viewRouter.currentPage {
                case .home:
                    HomePage(isAdding: $isAdding)
                case .settings:
                    SettingsPage()
                case .tutorial:
                    Tutorial()
                }
                
                if (isAdding) {
                    AddPage(isAdding: $isAdding)
                }
                
                if viewRouter.currentPage != .tutorial {
                    NavigationBar(isAdding: self.$isAdding)
                }
            }
            .environmentObject(viewRouter)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
