//
//  SporadicWidget.swift
//  SporadicWidget
//
//  Created by brendan on 12/10/23.
//

import WidgetKit
import SwiftUI
import CloudKit

struct SingleExerciseWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SingleExerciseEntry {
        SingleExerciseEntry(date: Date(), amount: 100, configuration: .siblingSquad)
    }

    func snapshot(for configuration: SingleExerciseConfigurationIntent, in context: Context) async -> SingleExerciseEntry {
        if context.isPreview {
            return SingleExerciseEntry(date: Date(), amount: 100, configuration: .siblingSquad)
        }
        else {
            let amount = await getAmountFrom(configuration: configuration)
            
            return SingleExerciseEntry(date: Date(), amount: amount, configuration: configuration)
        }
    }
    
    func getAmountFrom(configuration: SingleExerciseConfigurationIntent) async -> Double {
        guard let groupRecord = configuration.exercise?.groupRecord else { return 0 }
        guard let activityName = configuration.exercise?.activityName else { return 0 }
        guard let activityUnit = configuration.exercise?.activityUnit else { return 0 }
        guard let group = UserGroup(from: groupRecord) else { return 0 }
        guard let user = try? await CloudKitHelper.shared.getCurrentUser(forceSync: false) else { return 0 }
        
        if let challenges = try? await CloudKitHelper.shared.fetchCompletedChallengesForActivity(group: group, activityName: activityName, activityUnit: activityUnit) {
            let statsManager = StatsManager()
            let stats = statsManager.getPersonalStatsForOneExercise(challenges: challenges, user: user)
            
            return stats.0
        }
        
        return 0
    }
    
    func timeline(for configuration: SingleExerciseConfigurationIntent, in context: Context) async -> Timeline<SingleExerciseEntry> {
        let amount = await getAmountFrom(configuration: configuration)
            
        return Timeline(entries: [SingleExerciseEntry(date: Date(), amount: amount, configuration: configuration)], policy: .never)
    }
}

struct SingleExerciseEntry: TimelineEntry {
    let date: Date
    let amount: Double
    let configuration: SingleExerciseConfigurationIntent
}

struct SmallSingleExerciseWidgetEntryView : View {
    var entry: SingleExerciseWidgetProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        VStack(alignment: .leading) {
            Image(entry.configuration.exercise?.template != nil ? (entry.configuration.exercise?.activityName ?? "") : "Custom Activity Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 27, height: 27)
                .padding(5)
                .background(Circle().foregroundColor(entry.configuration.exercise?.template?.color ?? Color("CustomExercise")))
            
            TextHelper.text(key: entry.configuration.exercise?.groupName ?? "", alignment: .leading, type: .h7)
                .minimumScaleFactor(0.8)
            
            TextHelper.text(key: entry.configuration.exercise?.activityName ?? "", alignment: .leading, type: .h4)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline) {
                Text(entry.amount.removeZerosFromEnd())
                    .font(Font.custom("Lexend-SemiBold", size: 25, relativeTo: .title))
                    .foregroundColor(Color("BrandPurple"))
                TextHelper.text(key: "total " + getLabel(), alignment: .leading, type: .h5, color: Color("BrandPurple"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
            }
        }
        .background(Image("BackgroundImage"))
    }
    
    func getLabel() -> String {
        var unit = entry.configuration.exercise?.activityUnit ?? ""
        if entry.amount == 1 {
            if unit.last == "s" {
                let _ = unit.popLast()
            }
        }
        
        return unit
    }
}

struct SmallSingleExerciseWidget: Widget {
    let kind: String = "SingleExerciseWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SingleExerciseConfigurationIntent.self,
            provider: SingleExerciseWidgetProvider()) { entry in
            SmallSingleExerciseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])
    }
}

extension SingleExerciseConfigurationIntent {
    fileprivate static var siblingSquad: SingleExerciseConfigurationIntent {
        let intent = SingleExerciseConfigurationIntent()
        intent.exercise = SingleExerciseEntity(
            id: "Id", 
            name: "Sibling Squad: Run",
            groupName: "Pompous Planking Posse",
            groupRecord: CKRecord(recordType: "UserGroup"),
            groupEmoji: "😃",
            groupColor: 1,
            activityName: "Jumping Jacks",
            activityUnit: "miles",
            template: ActivityTemplate(id: 1, name: "Run", minValue: 0.25, maxValue: 20.0, selectedMin: 1.0, selectedMax: 3.0, minRange: 0.25, unit: .miles, category: .cardio)
        )
        return intent
    }
}

struct SmallSingleExerciseWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallSingleExerciseWidgetEntryView(entry: SingleExerciseEntry(date: Date(), amount: 1, configuration: .siblingSquad))
                .containerBackground(.fill.tertiary, for: .widget)
                .preferredColorScheme(.light)
            
            SmallSingleExerciseWidgetEntryView(entry: SingleExerciseEntry(date: Date(), amount: 100, configuration: .siblingSquad))
                .containerBackground(.fill.tertiary, for: .widget)
                .preferredColorScheme(.dark)
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

