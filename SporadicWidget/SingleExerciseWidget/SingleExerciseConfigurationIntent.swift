//
//  AppIntent.swift
//  SporadicWidget
//
//  Created by brendan on 12/10/23.
//

import WidgetKit
import AppIntents

struct SingleExerciseConfigurationIntent: WidgetConfigurationIntent, AppIntent {
    static var title: LocalizedStringResource = "Select An Exercise"
    static var description = IntentDescription("Selects the exercise to display information for.")

    @Parameter(title: "Exercise")
    var exercise: SingleExerciseEntity?
}
