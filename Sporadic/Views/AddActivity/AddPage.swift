//
//  AddPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI
import CoreData

struct AddPage: View {
//    @ObservedObject var viewModel: AddActivityViewModel
    
    let textHelper = TextHelper()
    var items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 100)), count: 2)
    
    @Binding var isAdding: Bool
    
    init(isAdding: Binding<Bool>) {
//        viewModel = AddActivityViewModel(dataController: DataController.shared, activityTemplateHelper: ActivityTemplateHelper())
        self._isAdding = isAdding
    }
    
    var body: some View {
        VStack {
//            ScrollView(.vertical) {
//                textHelper.GetTextByType(key: "AddANewActivity", alignment: .leading, type: .title)
//                    .padding()
//
//                textHelper.GetTextByType(key: "SelectANewActivity", alignment: .leading, type: .medium)
//                    .padding()
//
//                LazyVGrid(columns: items, alignment: .center) {
//                    ForEach(Array(viewModel.activities.enumerated()), id: \.offset) { index, activity in
//                        ActivityWidget(activity: activity, isAdding: $isAdding)
//                    }
//                }
//                .padding()
//            }
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
