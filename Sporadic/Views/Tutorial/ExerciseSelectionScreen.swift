//
//  ExerciseSelectionScreen.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/16/24.
//

import SwiftUI

struct ExerciseSelectionScreen: View {
    @State var selectedTemplates = [ActivityTemplate]()
    
    let templates = ActivityTemplateHelper.templates.filter({ $0.canDoIndoors == true && $0.requiresEquipment == false })
    
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 3)
    
    var body: some View {
        LazyVGrid(columns: items, spacing: 17) {
            ForEach(templates) { template in
                Button(action: {
                    selectedTemplates.append(template)
                }) {
                    ActivityWidget(template: template)
                }
                .buttonStyle(ButtonPressAnimationStyle())
            }
        }
        .padding()
    }
}

#Preview {
    ExerciseSelectionScreen()
}
