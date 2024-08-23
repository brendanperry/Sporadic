//
//  GroupStreakWidget.swift
//  Sporadic
//
//  Created by brendan on 1/1/24.
//

import WidgetKit
import SwiftUI
import CloudKit

struct GroupStreakProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> GroupStreakEntry {
        GroupStreakEntry(date: Date(), streak: 8, configuration: .siblingSquad)
    }

    func snapshot(for configuration: GroupStreakConfigurationIntent, in context: Context) async -> GroupStreakEntry {
        if context.isPreview {
            return GroupStreakEntry(date: Date(), streak: 8, configuration: .siblingSquad)
        }
        else {
            let amount = await getStreakFrom(configuration: configuration)
            
            return GroupStreakEntry(date: Date(), streak: amount, configuration: configuration)
        }
    }
    
    func getStreakFrom(configuration: GroupStreakConfigurationIntent) async -> Int {
        guard let groupRecord = configuration.group?.groupRecord else { return 0 }
        guard let group = UserGroup(from: groupRecord) else { return 0 }
        
        let result = await CloudKitHelper.shared.getStreakForGroup(group: group)
        
        group.streak = result.0
        group.brokenStreakDate = result.1
        
        CloudKitHelper.shared.updateGroupStreak(group: group) { error in
            print(error?.localizedDescription ?? "")
        }
        
        return result.0
    }
    
    func timeline(for configuration: GroupStreakConfigurationIntent, in context: Context) async -> Timeline<GroupStreakEntry> {
        let streak = await getStreakFrom(configuration: configuration)
            
        return Timeline(entries: [
                GroupStreakEntry(date: Date(), streak: streak, configuration: configuration)
            ], policy: .never)
    }
}

struct GroupStreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let configuration: GroupStreakConfigurationIntent
}

struct GroupStreakWidgetEntryView : View {
    var entry: GroupStreakProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        VStack(alignment: .leading) {
            GroupIcon(emoji: entry.configuration.group?.emoji ?? "", backgroundColor:  entry.configuration.group?.color ?? 0)
            
            TextHelper.text(key: entry.configuration.group?.name ?? "", alignment: .leading, type: .h7)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            TextHelper.text(key: "Streak", alignment: .leading, type: .h4)
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline) {
                Text("\(entry.streak)")
                    .font(Font.custom("Lexend-SemiBold", size: 25, relativeTo: .title))
                    .foregroundColor(Color("BrandPurple"))
                TextHelper.text(key: "days ", alignment: .leading, type: .h5, color: Color("BrandPurple"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
            }
        }
        .background(Image("BackgroundImage"))
    }
}

struct GroupStreakWidget: Widget {
    let kind: String = "GroupStreakWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: GroupStreakConfigurationIntent.self,
            provider: GroupStreakProvider()) { entry in
            GroupStreakWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])
    }
}

extension GroupStreakConfigurationIntent {
    fileprivate static var siblingSquad: GroupStreakConfigurationIntent {
        let intent = GroupStreakConfigurationIntent()
        intent.group = GroupEntity(
            id: "Id",
            name: "Sibling Squad",
            emoji: "😎",
            color: 0,
            groupRecord: CKRecord(recordType: "UserGroup")
        )
        return intent
    }
}

struct GroupStreakWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GroupStreakWidgetEntryView(entry: GroupStreakEntry(date: Date(), streak: 8, configuration: .siblingSquad))
                .containerBackground(.fill.tertiary, for: .widget)
                .preferredColorScheme(.light)
            
            GroupStreakWidgetEntryView(entry: GroupStreakEntry(date: Date(), streak: 8, configuration: .siblingSquad))
                .containerBackground(.fill.tertiary, for: .widget)
                .preferredColorScheme(.dark)
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

