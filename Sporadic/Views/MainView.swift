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
    
    var body: some View {
        ZStack {
            Spacer()
            
            switch viewRouter.currentPage {
            case .home:
                HomePage()
            case .settings:
                SettingsPage()
            case .tutorial:
                Text("Tutorial")
            }
            
            HStack {
                Spacer()
                if viewRouter.currentPage == .home {
                    TabBarIcon(viewRouter: viewRouter, assignedPage: .home, icon: "HomeOn")
                    Spacer()
                    TabBarIcon(viewRouter: viewRouter, assignedPage: .settings, icon: "SettingsOff")
                } else {
                    TabBarIcon(viewRouter: viewRouter, assignedPage: .home, icon: "HomeOff")
                    Spacer()
                    TabBarIcon(viewRouter: viewRouter, assignedPage: .settings, icon: "SettingsOn")
                }
                Spacer()
            }
            .padding()
            .background(Color("ActivityBackgroundColor"))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .frame(maxHeight: .infinity, alignment: .bottom)

        }
        .environmentObject(activityViewModel)
//        ZStack {
//            TabView(selection: $selectedTab) {
//                HomePage()
//                    .onTapGesture {
//                        selectedTab = 0
//                    }
//                    .tabItem {
//                        Image(systemName: "house")
//                    }
//                    .tag(0)
//                SettingsPage()
//                    .onTapGesture {
//                        selectedTab = 1
//                    }
//                    .tabItem {
//                        Image(systemName: "gear")
//                    }
//                    .tag(1)
//            }
//            .onChange(of: selectedTab) { newValue in
//                let impact = UIImpactFeedbackGenerator(style: .light)
//                impact.impactOccurred()
//            }
//            .environmentObject(activityViewModel)
//        }
    }
}

struct TabBarIcon: View {
    @StateObject var viewRouter: ViewRouter
    let assignedPage: Page
    let icon: String
     
     var body: some View {
        Image(icon)
            .resizable()
            .frame(width: 45, height: 45, alignment: .center)
            .onTapGesture {
                 viewRouter.currentPage = assignedPage
             }
     }
 }

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
