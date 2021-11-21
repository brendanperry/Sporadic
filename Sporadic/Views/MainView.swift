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
    @State var addButtonSize = 0.0
    @State var open = false

    @AppStorage(UserPrefs.appearance.rawValue)
    var appTheme = "System"
    
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                switch viewRouter.currentPage {
                case .home:
                    HomePage()
                case .settings:
                    SettingsPage()
                case .tutorial:
                    Text("Tutorial")
                }
                
                VStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: self.screenWidth, height: open ? self.screenHeight - geometry.safeAreaInsets.top : 0, alignment: .bottom)
                        .animation(Animation.easeInOut(duration: 0.25), value: self.open)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)

                ZStack {
                    
                    VStack {
                        Spacer()
                        Image("NavBar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: self.screenWidth * 0.90, height: 65, alignment: .bottom)
                            .padding()
                    }
                    .frame(maxHeight: .infinity)
                    
                    HStack {
                        Spacer()
                        TabBarIcon(viewRouter: viewRouter, assignedPage: .home, icon: viewRouter.currentPage == .home ? "HomeOn" : "HomeOff")
                            .offset(y: self.open ? 75 : 0)
                        Spacer()
                        AddButton(open: self.$open)
                        Spacer()
                        TabBarIcon(viewRouter: viewRouter, assignedPage: .settings, icon: viewRouter.currentPage == .home ? "SettingsOff" : "SettingsOn")
                            .offset(y: self.open ? 75 : 0)
                    Spacer()
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
            }
            .environmentObject(activityViewModel)
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

struct ButtonPressAnimationStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct AddButton: View {
    @Binding var open: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.open.toggle()
            }
        }){
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40, alignment: .center)
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 45, height: 45, alignment: .center)
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: self.open ? 45.0 : 0.0))
                    .scaleEffect(1.1)
                }
                .offset(y: -15)
        }
        .buttonStyle(ButtonPressAnimationStyle())
        .animation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.0), value: open)
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
            .padding(10)
     }
 }

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

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
