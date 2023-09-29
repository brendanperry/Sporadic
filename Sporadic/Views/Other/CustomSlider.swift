//
//  CustomSlider.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/14/22.
//

import Foundation
import SwiftUI

struct CustomSlider: View {
    let lineHeight: Double
    let lineWidth: Double
    let lineCornerRadius: Double
    let circleWidth: Double
    let circleShadowRadius: Double
    let roundToNearest: Double
    let minValue: Double
    let maxValue: Double
    let circleBorder: Double
    let circleBorderColor: Color
    let circleColor: Color
    let lineColorInRange: Color
    let lineColorOutOfRange: Color
    
    @Binding var selection: Double
    @State var sliderPosition: Double
    
    init(lineHeight: Double,
         lineWidth: Double,
         lineCornerRadius: Double,
         circleWidth: Double,
         circleShadowRadius: Double,
         roundToNearest: Double,
         minValue: Double,
         maxValue: Double,
         circleBorder: Double,
         circleBorderColor: Color,
         circleColor: Color,
         lineColorInRange: Color,
         lineColorOutOfRange: Color,
         selection: Binding<Double>) {
        self.lineHeight = lineHeight
        self.lineWidth = lineWidth
        self.lineCornerRadius = lineCornerRadius
        self.circleWidth = circleWidth
        self.circleShadowRadius = circleShadowRadius
        self.roundToNearest = roundToNearest
        self.minValue = minValue
        self.maxValue = maxValue
        self._selection = selection
        self.circleBorder = circleBorder
        self.circleBorderColor = circleBorderColor
        self.circleColor = circleColor
        self.lineColorInRange = lineColorInRange
        self.lineColorOutOfRange = lineColorOutOfRange

        self.sliderPosition = (selection.wrappedValue - minValue) / (maxValue - minValue) * self.lineWidth
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: self.lineCornerRadius, height: self.lineCornerRadius))
                    .frame(width: self.lineWidth, height: self.lineHeight, alignment: .center)
                    .foregroundColor(self.lineColorOutOfRange)
                RoundedRectangle(cornerSize: CGSize(width: self.lineCornerRadius, height: self.lineCornerRadius))
                    .frame(
                        width: self.sliderPosition,
                        height: self.lineHeight,
                        alignment: .center)
                    .position(
                        x: sliderPosition / 2,
                        y: geo.frame(in: .local).midY)
                    .foregroundColor(self.lineColorInRange)
                Circle()
                    .strokeBorder(self.circleBorderColor, lineWidth: self.circleBorder)
                    .background(Circle().fill(self.circleColor)
                        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4))
                    .frame(width: self.circleWidth, height: self.circleWidth, alignment: .center)
                    .position(x: self.sliderPosition, y: geo.frame(in: .local).midY)
                    .foregroundColor(self.circleColor)
                    .gesture(dragLeftSlider)
            }
        }
        .frame(width: self.lineWidth, height: self.circleWidth, alignment: .center)
    }

    var dragLeftSlider: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.location.x <= 0 {
                    self.sliderPosition = 0
                } else if value.location.x >= self.lineWidth {
                    self.sliderPosition = self.lineWidth
                } else {
                    self.sliderPosition = value.location.x
                    
                    let newValue = round((self.sliderPosition / self.lineWidth) * (self.maxValue - self.minValue) + self.minValue, toNearest: self.roundToNearest)

                if newValue != self.selection {
                    self.selection = newValue
                    generateHapticFeedback()
                }
            }
        }
    }
        
    func generateHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        let rounded = Darwin.round(value / toNearest) * toNearest

        return rounded == -0 ? 0 : rounded
    }
}
