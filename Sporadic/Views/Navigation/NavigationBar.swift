//
//  NavigationBar.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct NavigationBar: View {
    @ObservedObject var viewRouter: ViewRouter
    @State var homeIconOn: Bool
    @State var statsIconOn: Bool
    @State var settingsIconOn: Bool
    
    init(viewRouter: ViewRouter) {
        self.viewRouter = viewRouter
        
        if viewRouter.previousPage == .home && viewRouter.currentPage == .stats {
            _homeIconOn = .init(initialValue: true)
            _statsIconOn = .init(initialValue: false)
            _settingsIconOn = .init(initialValue: false)
        }
        else if viewRouter.previousPage == .home && viewRouter.currentPage == .settings {
            _homeIconOn = .init(initialValue: true)
            _settingsIconOn = .init(initialValue: false)
            _statsIconOn = .init(initialValue: false)
        }
        else if viewRouter.previousPage == .stats && viewRouter.currentPage == .home {
            _statsIconOn = .init(initialValue: true)
            _homeIconOn = .init(initialValue: false)
            _settingsIconOn = .init(initialValue: false)
        }
        else if viewRouter.previousPage == .stats && viewRouter.currentPage == .settings {
            _statsIconOn = .init(initialValue: true)
            _settingsIconOn = .init(initialValue: false)
            _homeIconOn = .init(initialValue: false)
        }
        else if viewRouter.previousPage == .settings && viewRouter.currentPage == .home {
            _settingsIconOn = .init(initialValue: true)
            _homeIconOn = .init(initialValue: false)
            _statsIconOn = .init(initialValue: false)
        }
        else if viewRouter.previousPage == .settings && viewRouter.currentPage == .stats {
            _settingsIconOn = .init(initialValue: true)
            _statsIconOn = .init(initialValue: false)
            _homeIconOn = .init(initialValue: false)
        }
        else {
            _homeIconOn = .init(initialValue: true)
            _statsIconOn = .init(initialValue: false)
            _settingsIconOn = .init(initialValue: false)
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Rectangle()
                    .foregroundColor(Color("Panel"))
                    .frame(maxWidth: .infinity, maxHeight: 123, alignment: .bottom)
                    .offset(y: 50)
                    .shadow(radius: 3)
                    .ignoresSafeArea()
            }
            .frame(maxHeight: .infinity)
            
            HStack {
                Spacer()
                HomeIcon(viewRouter: viewRouter, isOn: homeIconOn)
                Spacer()
                StatsIcon(viewRouter: viewRouter, isOn: statsIconOn)
                Spacer()
                SettingsIcon(viewRouter: viewRouter, isOn: settingsIconOn)
                Spacer()
            }
            .animation(.easeInOut, value: homeIconOn)
            .animation(.easeInOut, value: statsIconOn)
            .animation(.easeInOut, value: settingsIconOn)
            .padding()
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: 10)
            .onAppear {
                withAnimation {
                    if viewRouter.previousPage == .home && viewRouter.currentPage == .stats {
                        self.homeIconOn = false
                        self.statsIconOn = true
                    }
                    else if viewRouter.previousPage == .home && viewRouter.currentPage == .settings {
                        homeIconOn = false
                        settingsIconOn = true
                    }
                    else if viewRouter.previousPage == .stats && viewRouter.currentPage == .home {
                        statsIconOn = false
                        homeIconOn = true
                    }
                    else if viewRouter.previousPage == .stats && viewRouter.currentPage == .settings {
                        statsIconOn = false
                        settingsIconOn = true
                    }
                    else if viewRouter.previousPage == .settings && viewRouter.currentPage == .home {
                        settingsIconOn = false
                        homeIconOn = true
                    }
                    else if viewRouter.previousPage == .settings && viewRouter.currentPage == .stats {
                        settingsIconOn = false
                        statsIconOn = true
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct HomeIcon: View {
    @ObservedObject var viewRouter: ViewRouter
    let isOn: Bool

    var body: some View {
        ZStack {
            Image(isOn ? "Home Outline Active" : "Home Outline Inactive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45, alignment: .center)
            
            Image(isOn ? "Home Inside Active" : "Home Inside Inactive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25, alignment: .center)
                .scaleEffect(isOn ? 1.1 : 1)
        }
        .onTapGesture {
            viewRouter.navigateTo(.home)
        }
     }
 }

struct StatsIcon: View {
    @ObservedObject var viewRouter: ViewRouter
    let isOn: Bool

    var body: some View {
        ZStack {
            Image(isOn ? "Stats Outline Active" : "Stats Outline Inactive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 62, height: 62, alignment: .center)
                .rotationEffect(isOn ? Angle(degrees: 45) : Angle(degrees: 0))
            
            Image(isOn ? "Stats Inside Active" : "Stats Inside Inactive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20, alignment: .center)
        }
        .onTapGesture {
            viewRouter.navigateTo(.stats)
        }
     }
 }

struct SettingsIcon: View {
    @ObservedObject var viewRouter: ViewRouter
    let isOn: Bool

    var body: some View {
        Image(isOn ? "SettingsOn" : "SettingsOff")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 45, height: 45, alignment: .center)
            .rotationEffect(isOn ? Angle(degrees: 45) : Angle(degrees: 0))
            .onTapGesture {
                viewRouter.navigateTo(.settings)
            }
     }
 }
