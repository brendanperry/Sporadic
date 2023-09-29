//
//  TabBarIcon.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct TabBarIcon: View {
    @ObservedObject var viewRouter: ViewRouter
    let assignedPage: Page
    let icon: String

    var body: some View {
        Image(icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 45, height: 45, alignment: .center)
            .onTapGesture {
                viewRouter.navigateTo(assignedPage)
            }
     }
 }
