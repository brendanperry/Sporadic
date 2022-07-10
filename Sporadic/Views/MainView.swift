//
//  MainView.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewRouter = ViewRouter()
    
    var body: some View {
        ZStack(alignment: .trailing) {
            switch viewRouter.currentPage {
            case .home:
                HomePage()
            case .settings:
                SettingsPage()
            case .tutorial:
                Tutorial()
            case .stats:
                Stats()
            }
        }
        .environmentObject(viewRouter)
        .onOpenURL { url in
          print(url.absoluteString)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
