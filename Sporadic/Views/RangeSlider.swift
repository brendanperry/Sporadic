//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by Brendan Perry on 10/7/21.
//

import SwiftUI

struct RangeSliderPage: View {
    @AppStorage ("testLeft8")
    var left = -10.0
    
    @AppStorage ("testRight8")
    var right = 10.0
    
    var body: some View {
        VStack {
            Text("Left Value: \(self.left.removeZerosFromEnd())")
            Text("Right Value: \(self.right.removeZerosFromEnd())")
            
            RangeSlider(lineHeight: 3, lineWidth: 250, lineCornerRadius: 10, circleWidth: 15, circleShadowRadius: 1, roundToNearest: 0.5, minRange: 2, minValue: -10, maxValue: 10, lineColorInRange: .blue, lineColorOutOfRange: Color(UIColor.lightGray), circleColor: .white, leftValue: $left, rightValue: $right)
        }
    }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return String(formatter.string(from: number) ?? "")
    }
}

struct RangeSlider: View {
    let lineHeight: Double
    let lineWidth: Double
    let lineCornerRadius: Double
    let circleWidth: Double
    let circleShadowRadius : Double
    let roundToNearest: Double
    let minRange: Double
    let minValue: Double
    let maxValue: Double
    let lineColorInRange : Color
    let lineColorOutOfRange : Color
    let circleColor : Color
    
    @Binding var leftValue : Double
    @Binding var rightValue : Double
    
    @State var leftSliderPosition : Double
    @State var rightSliderPosition : Double
    
    init(lineHeight: Double,
         lineWidth: Double,
         lineCornerRadius: Double,
         circleWidth: Double,
         circleShadowRadius: Double,
         roundToNearest: Double,
         minRange: Double,
         minValue: Double,
         maxValue: Double,
         lineColorInRange: Color,
         lineColorOutOfRange: Color,
         circleColor: Color,
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
        self.lineColorInRange = lineColorInRange
        self.lineColorOutOfRange = lineColorOutOfRange
        self.circleColor = circleColor
        
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
                    .frame(width: self.rightSliderPosition - self.leftSliderPosition, height: self.lineHeight, alignment: .center)
                    .position(x: (self.rightSliderPosition - self.leftSliderPosition) / 2 + leftSliderPosition, y: geo.frame(in: .local).midY)
                    .foregroundColor(self.lineColorInRange)
                Circle()
                    .frame(width: self.circleWidth, height: self.circleWidth, alignment: .center)
                    .position(x: self.leftSliderPosition, y: geo.frame(in: .local).midY)
                    .foregroundColor(self.circleColor)
                    .shadow(radius: self.circleShadowRadius)
                    .gesture(dragLeftSlider)
                Circle()
                    .frame(width: self.circleWidth, height: self.circleWidth, alignment: .center)
                    .position(x: self.rightSliderPosition, y: geo.frame(in: .local).midY)
                    .foregroundColor(self.circleColor)
                    .shadow(radius: self.circleShadowRadius)
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
                
                if (newValue != self.leftValue) {
                    self.leftValue = newValue
                    self.GenerateHapticFeedback()
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
                
                if (newValue != self.rightValue) {
                    self.rightValue = newValue
                    self.GenerateHapticFeedback()
                }
            }
    }
    
    func GenerateHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    func round(_ value: Double, toNearest: Double) -> Double {
        let rounded = Darwin.round(value / toNearest) * toNearest
        
        return rounded == -0 ? 0 : rounded
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        RangeSliderPage()
    }
}
