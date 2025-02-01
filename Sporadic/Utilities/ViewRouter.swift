//
//  ViewRouter.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/25/21.
//

import SwiftUI
import Aptabase

enum Page {
    case home
    case settings
    case stats
    case tutorial
}

class ViewRouter: ObservableObject {
    private(set) var currentPage: Page
    @Published var previousPage: Page
    
    init() {
        if !UserDefaults.standard.bool(forKey: UserPrefs.tutorial.rawValue) {
            Aptabase.shared.trackEvent("tutorial_started")
            currentPage = .tutorial
        } else {
            currentPage = .home
        }
        
        previousPage = .home
    }
    
    public func navigateTo(_ page: Page) {
        if currentPage != page {
            previousPage = currentPage
            
            withAnimation {
                currentPage = page
            }
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
}
