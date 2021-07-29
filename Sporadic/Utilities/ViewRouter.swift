//
//  ViewRouter.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/25/21.
//

import SwiftUI

enum Page {
    case home
    case settings
    case tutorial
 }

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .home
}
