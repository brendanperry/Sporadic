//
//  AddPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct AddPage: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var activities: FetchedResults<Activity>
    let textHelper = TextHelper()
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                textHelper.GetTextByType(text: "Add a new activity", isCentered: false, type: .title)
                    .padding()
                
                textHelper.GetTextByType(text: "Select a new activity to be challenged with.", isCentered: false, type: .medium)
                    .padding()
                
                LazyVGrid(columns: items, alignment: .center) {
                    ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                        if (!activity.isEnabled) {
                            ActivityWidgetAdd(activity: activity)
                        }
                    }
                }
                .padding()
            }
        }
        .background(
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .transition(.move(edge: .bottom))
        .zIndex(1)
    }
}
