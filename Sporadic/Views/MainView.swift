//
//  MainView.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var statsViewModel = StatsViewModel()
    @StateObject var viewRouter = ViewRouter()
    @State var showJoinGroup = false
    @State var groupId = ""
    
    var body: some View {
        ZStack(alignment: .trailing) {
            switch viewRouter.currentPage {
            case .home:
                HomePage(viewModel: homeViewModel)
            case .settings:
                SettingsPage()
            case .tutorial:
                HomePage(viewModel: homeViewModel)
            case .stats:
                Stats(viewModel: statsViewModel, homeViewModel: homeViewModel)
            }
        }
        .environmentObject(viewRouter)
        .onOpenURL { url in
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            
            if let group = components?.queryItems?.first(where: { $0.name == "group" }) {
                if let groupId = group.value {
                    self.groupId = groupId
                }
            }
        }
        .onChange(of: groupId) { _ in
            if !groupId.isEmpty {
                showJoinGroup = true
            }
        }
        .popover(isPresented: $showJoinGroup) {
            JoinGroup(viewModel: JoinGroupViewModel(groupId: groupId, homeViewModel: homeViewModel), groupId: $groupId)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
