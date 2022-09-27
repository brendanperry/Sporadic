//
//  AddActivityViewModel.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/20/22.
//

import Foundation
import Combine

class AddActivityViewModel: ObservableObject {
    @Published var name = ""
    @Published var unit = ActivityUnit.miles
    @Published var minValue = 1.0
    @Published var maxValue = 3.0
    @Published var errorMessage = ""
    @Published var showError = false
    
    let unitPublisher = PassthroughSubject<ActivityUnit, Never>()
    
    func resetSlider(newUnit: ActivityUnit) {
        unitPublisher.send(newUnit)
    }
    
    func updateActivity(activity: Activity) {
        CloudKitHelper.shared.updateActivity(activity: activity) { [weak self] error in
            if let _ = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Could not save activity. Please check your connection and try again."
                    self?.showError = true
                }
            }
        }
    }
}
