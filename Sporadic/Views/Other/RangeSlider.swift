//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by Brendan Perry on 10/7/21.
//

import SwiftUI

struct RangeSlider: View {
    let lineHeight: Double
    let lineWidth: Double
    let lineCornerRadius: Double
    let circleWidth: Double
    let circleShadowRadius: Double
    let roundToNearest: Double
    let minRange: Double
    let minValue: Double
    let maxValue: Double
    let circleBorder: Double
    let circleBorderColor: Color
    let circleColor: Color
    let lineColorInRange: Color
    let lineColorOutOfRange: Color

    @Binding var leftValue: Double
    @Binding var rightValue: Double

    @State var leftSliderPosition: Double
    @State var rightSliderPosition: Double

    init(lineHeight: Double,
         lineWidth: Double,
         lineCornerRadius: Double,
         circleWidth: Double,
         circleShadowRadius: Double,
         roundToNearest: Double,
         minRange: Double,
         minValue: Double,
         maxValue: Double,
         circleBorder: Double,
         circleBorderColor: Color,
         circleColor: Color,
         lineColorInRange: Color,
         lineColorOutOfRange: Color,
         leftValue: Binding<Double>,
         rightValue: Binding<Double>) {
        self.lineHeight = lineHeight
        self.lineWidth = lineWidth
        self.lineCornerRadius = lineCornerRadius
        self.circleWidth = circleWidth
        self.circleShadowRadius = circleShadowRadius
        self.roundToNearest = roundToNearest
        self.minRange = minRange
        self.minValue = minValue
        self.maxValue = maxValue
        self._leftValue = leftValue
        self._rightValue = rightValue
        self.circleBorder = circleBorder
        self.circleBorderColor = circleBorderColor
        self.circleColor = circleColor
        self.lineColorInRange = lineColorInRange
        self.lineColorOutOfRange = lineColorOutOfRange

        self.leftSliderPosition = (leftValue.wrappedValue - minValue) / (maxValue - minValue) * self.lineWidth
        self.rightSliderPosition = (rightValue.wrappedValue - minValue) / (maxValue - minValue) * self.lineWidth
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: self.lineCornerRadius, height: self.lineCornerRadius))
                    .frame(width: self.lineWidth, height: self.lineHeight, alignment: .center)
                    .foregroundColor(self.lineColorOutOfRange)
                RoundedRectangle(cornerSize: CGSize(width: self.lineCornerRadius, height: self.lineCornerRadius))
                    .frame(
                        width: self.rightSliderPosition - self.leftSliderPosition,
                        height: self.lineHeight,
                        alignment: .center)
                    .position(
                        x: (self.rightSliderPosition - self.leftSliderPosition) / 2 + leftSliderPosition,
                        y: geo.frame(in: .local).midY)
                    .foregroundColor(self.lineColorInRange)
                Circle()
                    .strokeBorder(self.circleBorderColor, lineWidth: self.circleBorder)
                    .background(Circle().fill(self.circleColor).shadow(radius: self.circleShadowRadius))
                    .frame(width: self.circleWidth, height: self.circleWidth, alignment: .center)
                    .position(x: self.leftSliderPosition, y: geo.frame(in: .local).midY)
                    .foregroundColor(self.circleColor)
                    .gesture(dragLeftSlider)
                Circle()
                    .strokeBorder(self.circleBorderColor, lineWidth: self.circleBorder)
                    .background(Circle().fill(self.circleColor).shadow(radius: self.circleShadowRadius))
                    .frame(width: self.circleWidth, height: self.circleWidth, alignment: .center)
                    .position(x: self.rightSliderPosition, y: geo.frame(in: .local).midY)
                    .gesture(dragRightSlider)
            }
        }
        .frame(width: self.lineWidth, height: self.circleWidth, alignment: .center)
    }

    var dragLeftSlider: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.location.x <= 0 {
                    self.leftSliderPosition = 0
                } else if value.location.x <= self.rightSliderPosition - (minRange * (self.lineWidth / (self.maxValue - self.minValue))) {
                    self.leftSliderPosition = value.location.x
                } else {
                    self.leftSliderPosition = self.rightSliderPosition - (minRange * (self.lineWidth / (self.maxValue - self.minValue)))
                }

                let newValue = round((self.leftSliderPosition / self.lineWidth) * (self.maxValue - self.minValue) + self.minValue, toNearest: self.roundToNearest)

                if newValue != self.leftValue {
                    self.leftValue = newValue
                    self.generateHapticFeedback()
                }
            }
    }

    var dragRightSlider: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.location.x >= self.lineWidth {
                    self.rightSliderPosition = self.lineWidth
                } else if value.location.x >= self.leftSliderPosition + (minRange * (self.lineWidth / (self.maxValue - self.minValue))) {
                    self.rightSliderPosition = value.location.x
                } else {
                    self.rightSliderPosition = self.leftSliderPosition + (minRange * (self.lineWidth / (self.maxValue - self.minValue)))
                }

                let newValue = round((self.rightSliderPosition / self.lineWidth) * (self.maxValue - self.minValue) + self.minValue, toNearest: self.roundToNearest)

                if newValue != self.rightValue {
                    self.rightValue = newValue
                    self.generateHapticFeedback()
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