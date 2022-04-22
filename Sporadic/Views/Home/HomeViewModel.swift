//
//  HomeViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/23/22.
//

import Foundation
import CoreData

class HomeViewModel : ObservableObject {
    let dataHelper: Repository
    
    @Published var challenge: Challenge?
    
    init(dataHelper: Repository) {
        self.dataHelper = dataHelper
        
        challenge = getDailyActivity()
    }
    
    func saveChallenge() {
        dataHelper.saveChanges()
    }
    
    func getDailyActivity() -> Challenge? {
        return dataHelper.fetchCurrentChallenge()
    }
}
