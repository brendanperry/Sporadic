//
//  AddPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct AddPage: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    let textHelper = TextHelper()
    let isAdding: Bool
    let topSafeArea: Double
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    var body: some View {
        VStack {
            VStack {
                ScrollView(.vertical) {
                    textHelper.GetTextByType(text: "Add a new activity", isCentered: false, type: .title)
                        .padding()
                    
                    textHelper.GetTextByType(text: "Select a new activity to be challenged with.", isCentered: false, type: .medium)
                        .padding()
                    
                    LazyVGrid(columns: items, alignment: .center) {
                        ForEach(Array(activityViewModel.activities.enumerated()), id: \.offset) { index, activity in
                            if (!activity.isEnabled) {
                                ActivityWidgetAdd(activity: activity)
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 75)
                    .clipped()
                }
            }
            .background(
                Rectangle()
                    .foregroundColor(.clear)
            )
            .frame(width: UIScreen.main.bounds.width, height: isAdding ? UIScreen.main.bounds.height - self.topSafeArea : 0, alignment: .bottom)
            .animation(Animation.easeInOut(duration: 0.25), value: self.isAdding)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
