//
//  SporadicWidgetBundle.swift
//  SporadicWidget
//
//  Created by brendan on 12/10/23.
//

import WidgetKit
import SwiftUI

@main
struct SporadicWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallSingleExerciseWidget()
        GroupStreakWidget()
    }
}
