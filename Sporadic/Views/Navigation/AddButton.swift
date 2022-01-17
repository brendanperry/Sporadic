//
//  AddButton.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import SwiftUI

struct AddButton: View {
    @Binding var isAdding: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.isAdding.toggle()
                
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }){
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40, alignment: .center)
                
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 45, height: 45, alignment: .center)
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: self.isAdding ? 45.0 : 0.0))
                    .scaleEffect(1.1)
                }
                .offset(y: -15)
        }
        .buttonStyle(ButtonPressAnimationStyle())
        .animation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.0), value: self.isAdding)
    }
    
    private struct ButtonPressAnimationStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        }
    }
}
