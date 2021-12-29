//
//  ActivitiesAdd.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/15/21.
//

import SwiftUI

struct ActivitiesAdd: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    let textHelper = TextHelper()
    
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    var body: some View {
        LazyVGrid(columns: items, alignment: .center) {
            ForEach(Array(activityViewModel.activities.enumerated()), id: \.offset) { index, activity in
                ActivityWidgetAdd(activity: activity)
            }
        }
        .padding()
        .padding(.bottom, 75)
        .clipped()
    }
}
