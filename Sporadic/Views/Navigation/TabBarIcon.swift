//
//  TabBarIcon.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct TabBarIcon: View {
    @StateObject var viewRouter: ViewRouter
    let assignedPage: Page
    let icon: String

    var body: some View {
        Image(icon)
            .resizable()
            .frame(width: 45, height: 45, alignment: .center)
            .onTapGesture {
                if (viewRouter.currentPage != assignedPage) {
                    viewRouter.currentPage = assignedPage

                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
             }
            .padding(10)
     }
 }
