//
//  Activities.swift
//  Sporadic
//
//  Created by Brendan Perry on 10/19/21.
//

import SwiftUI
import Introspect

struct ActivitiesHome: View {
    let textHelper = TextHelper()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var activities: FetchedResults<Activity>
    
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(text: Localize.getString("Activities"), isCentered: false, type: .medium)
                .padding(.leading)
                .padding(.top)
            
            LazyVGrid(columns: items, alignment: .center) {
                ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                    if (activity.isEnabled) {
                        ActivityWidget(activity: activity)
                    }
                }
            }
        }
    }
}
