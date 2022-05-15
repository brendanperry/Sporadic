//
//  Activities.swift
//  Sporadic
//
//  Created by Brendan Perry on 10/19/21.
//

import SwiftUI

struct ActivitiesHome: View {
    let textHelper = TextHelper()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var activities: FetchedResults<Activity>
    
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    @Binding var isAdding: Bool
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "Activities", alignment: .leading, type: .medium)
                .padding([.leading, .top])
            
            LazyVGrid(columns: items, alignment: .center) {
                ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                    if (activity.isEnabled) {
                        ActivityWidget(activity: activity, isAdding: $isAdding)
                    }
                }
            }
        }
    }
}
