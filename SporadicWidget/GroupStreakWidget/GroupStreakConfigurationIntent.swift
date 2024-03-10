//
//  GroupStreakConfigurationIntent.swift
//  Sporadic
//
//  Created by brendan on 1/1/24.
//

import WidgetKit
import AppIntents

struct GroupStreakConfigurationIntent: WidgetConfigurationIntent, AppIntent {
    static var title: LocalizedStringResource = "Select A Group"
    static var description = IntentDescription("Selects the group to display information for.")

    @Parameter(title: "Group")
    var group: GroupEntity?
}
