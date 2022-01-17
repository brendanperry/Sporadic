//
//  NavigationBar.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct NavigationBar: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var isAdding: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("NavBar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.90, height: 65, alignment: .bottom)
                    .padding()
                    .offset(y: self.isAdding ? 150 : 0)
            }
            .frame(maxHeight: .infinity)
            
            HStack {
                Spacer()
                TabBarIcon(viewRouter: viewRouter, assignedPage: .home, icon: viewRouter.currentPage == .home ? "HomeOn" : "HomeOff")
                    .offset(y: self.isAdding ? 150 : 0)
                    .disabled(self.isAdding)
                Spacer()
                AddButton(isAdding: self.$isAdding)
                Spacer()
                TabBarIcon(viewRouter: viewRouter, assignedPage: .settings, icon: viewRouter.currentPage == .home ? "SettingsOff" : "SettingsOn")
                    .offset(y: self.isAdding ? 150 : 0)
                    .disabled(self.isAdding)
                Spacer()
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .bottom)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .zIndex(2)
    }
}
