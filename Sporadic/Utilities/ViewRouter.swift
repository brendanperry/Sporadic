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
    @Published var currentPage: Page
    
    init() {
        if !UserDefaults.standard.bool(forKey: UserPrefs.tutorial.rawValue) {
            currentPage = .tutorial
        } else {
            currentPage = .home
        }
    }
}
