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
    
    @AppStorage(UserPrefs.Appearance.rawValue)
    var appTheme = "System"
    
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
            
            if (hasSafeAreaAtBottom()) {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Color("ActivityBackgroundColor")
                            .frame(
                                width: geometry.size.width,
                                height: geometry.safeAreaInsets.top,
                                alignment: .center)
                            .aspectRatio(contentMode: ContentMode.fit)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .environmentObject(activityViewModel)
        .preferredColorScheme(self.getColorSceme())
    }
    
    func hasSafeAreaAtBottom() -> Bool {
        if #available(iOS 13.0, *), UIApplication.shared.windows[0].safeAreaInsets.bottom > 0 {
            return true
        }
        
        return false
    }
    
    func getColorSceme() -> ColorScheme? {
        if (appTheme == "Light") {
            return .light
        }
        
        if (appTheme == "Dark") {
            return .dark
        }
        
        return nil
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
                
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
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
