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
    
    let unitPublisher = PassthroughSubject<ActivityUnit, Never>()
    
    func resetSlider(newUnit: ActivityUnit) {
        unitPublisher.send(newUnit)
    }
}
