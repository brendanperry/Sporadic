//
//  ExerciseSelectionScreen.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/16/24.
//

import SwiftUI

struct ExerciseSelectionScreen: View {
    @Binding var selectedTemplates: Set<ActivityTemplate>
    
    let templates = ActivityTemplateHelper.templates.filter({ $0.canDoIndoors == true && $0.requiresEquipment == false })
    
    var items: [GridItem] = Array(repeating: .init(.flexible(), spacing: 17), count: 3)
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Choose 3 exercises to get started.", alignment: .leading, type: .h1)
                .padding()

            TextHelper.text(key: "You can add or remove exercises as well as adjust the difficulty later.", alignment: .leading, type: .body)
                .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: items, spacing: 17) {
                    ForEach(templates) { template in
                        Button(action: {
                            if !selectedTemplates.contains(template) {
                                selectedTemplates.insert(template)
                            } else {
                                selectedTemplates.remove(template)
                            }
                        }) {
                            ActivityWidget(template: template)
                                .padding(2)
                                .background(
                                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius + 1)
                                        .foregroundStyle(selectedTemplates.contains(template) ? Color("BrandPurple") : .clear)
                                )
                        }
                        .buttonStyle(ButtonPressAnimationStyle())
                    }
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
    }
}

@available(iOS 18, *)
#Preview {
    @Previewable @State var selected = Set<ActivityTemplate>()
    ExerciseSelectionScreen(selectedTemplates: $selected)
}
