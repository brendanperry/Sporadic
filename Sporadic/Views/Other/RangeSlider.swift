//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by Brendan Perry on 10/7/21.
//

import SwiftUI
import Combine

struct RangeSlider: View {
    let lineHeight: Double
    let lineWidth: Double
    let lineCornerRadius: Double
    let circleWidth: Double
    let circleShadowRadius: Double
    @State var minValue: Double
    @State var maxValue: Double
    let circleBorder: Double
    let leftCircleBorderColor: Color
    let rightCircleBorderColor: Color
    let leftCircleColor: Color
    let rightCircleColor: Color
    let lineColorInRange: AnyShapeStyle
    let lineColorOutOfRange: Color
    let unitPublisher: AnyPublisher<ActivityUnit, Never>
    @State var hasAppeared = false
    @State var observers = Set<AnyCancellable>()
    var canclee: AnyCancellable?

    @Binding var leftValue: Double
    @Binding var rightValue: Double

    @State var leftSliderPosition: Double
    @State var rightSliderPosition: Double

    init(lineHeight: Double,
         lineWidth: Double,
         lineCornerRadius: Double,
         circleWidth: Double,
         circleShadowRadius: Double,
         minValue: Double,
         maxValue: Double,
         circleBorder: Double,
         leftCircleBorderColor: Color,
         rightCircleBorderColor: Color,
         leftCircleColor: Color,
         rightCircleColor: Color,
         lineColorInRange: AnyShapeStyle,
         lineColorOutOfRange: Color,
         leftValue: Binding<Double>,
         rightValue: Binding<Double>,
         unitPublisher: AnyPublisher<ActivityUnit, Never>) {
        self.lineHeight = lineHeight
        self.lineWidth = lineWidth
        self.lineCornerRadius = lineCornerRadius
        self.circleWidth = circleWidth
        self.circleShadowRadius = circleShadowRadius
        self.minValue = minValue
        self.maxValue = maxValue
        self._leftValue = leftValue
        self._rightValue = rightValue
        self.circleBorder = circleBorder
        self.leftCircleBorderColor = leftCircleBorderColor
        self.rightCircleBorderColor = rightCircleBorderColor
        self.leftCircleColor = leftCircleColor
        self.rightCircleColor = rightCircleColor
        self.lineColorInRange = lineColorInRange
        self.lineColorOutOfRange = lineColorOutOfRange
        self.unitPublisher = unitPublisher
        
        self.leftSliderPosition = (leftValue.wrappedValue - minValue) / (maxValue - minValue) * lineWidth
        self.rightSliderPosition = (rightValue.wrappedValue - minValue) / (maxValue - minValue) * lineWidth
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: lineCornerRadius, height: lineCornerRadius))
                    .frame(width: lineWidth, height: lineHeight, alignment: .center)
                    .foregroundColor(lineColorOutOfRange)
                RoundedRectangle(cornerSize: CGSize(width: lineCornerRadius, height: lineCornerRadius))
                    .fill(AnyShapeStyle(lineColorInRange))
                    .frame(
                        width: rightSliderPosition - leftSliderPosition,
                        height: lineHeight,
                        alignment: .center)
                    .position(
                        x: (rightSliderPosition - leftSliderPosition) / 2 + leftSliderPosition,
                        y: geo.frame(in: .local).midY)
                ZStack {
                    Circle()
                        .fill(leftCircleBorderColor)
                        .frame(width: circleWidth, height: circleWidth, alignment: .center)
                        .shadow(radius: circleShadowRadius)
                    Circle()
                        .fill(leftCircleColor)
                        .frame(width: circleWidth - circleBorder, height: circleWidth - circleBorder, alignment: .center)
                }
                .position(x: leftSliderPosition, y: geo.frame(in: .local).midY)
                .gesture(dragLeftSlider)
                
                ZStack {
                    Circle()
                        .fill(rightCircleBorderColor)
                        .frame(width: circleWidth, height: circleWidth, alignment: .center)
                        .shadow(radius: circleShadowRadius)
                    Circle()
                        .fill(rightCircleColor)
                        .frame(width: circleWidth - circleBorder, height: circleWidth - circleBorder, alignment: .center)
                }
                .position(x: rightSliderPosition, y: geo.frame(in: .local).midY)
                .gesture(dragRightSlider)
            }
        }
        .frame(width: lineWidth, height: circleWidth, alignment: .center)
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                
                DispatchQueue.main.async {
                    unitPublisher.sink { unit in
                        minValue = unit.minValue()
                        maxValue = unit.maxValue()
                        leftValue = unit.defaultMin()
                        rightValue = unit.defaultMax()
                        
                        leftSliderPosition = (leftValue - minValue) / (maxValue - minValue) * lineWidth
                        rightSliderPosition = (rightValue - minValue) / (maxValue - minValue) * lineWidth
                    }.store(in: &observers)
                }
            }
        }
    }

    var dragLeftSlider: some Gesture {
        DragGesture()
            .onChanged { value in
                updateLeftSlider(value: value)
            }
    }
    
    func updateLeftSlider(value: DragGesture.Value) {
        if value.location.x <= 0 {
            leftSliderPosition = 0
        } else if value.location.x <= rightSliderPosition - (minValue * (lineWidth / (maxValue - minValue))) {
            leftSliderPosition = value.location.x
        } else {
            leftSliderPosition = rightSliderPosition - (minValue * (lineWidth / (maxValue - minValue)))
        }

        let newValue = round((leftSliderPosition / lineWidth) * (maxValue - minValue) + minValue, toNearest: minValue)

        if newValue != leftValue {
            leftValue = newValue
            generateHapticFeedback()
        }
    }

    var dragRightSlider: some Gesture {
        DragGesture()
            .onChanged { value in
                updateRightSlider(value: value.location.x)
            }
    }
    
    func updateRightSlider(value: Double) {
        if value >= lineWidth {
            rightSliderPosition = lineWidth
        } else if value >= leftSliderPosition + (minValue * (lineWidth / (maxValue - minValue))) {
            rightSliderPosition = value
        } else {
            rightSliderPosition = leftSliderPosition + (minValue * (lineWidth / (maxValue - minValue)))
        }

        let newValue = round((rightSliderPosition / lineWidth) * (maxValue - minValue) + minValue, toNearest: minValue)

        if newValue != rightValue {
            rightValue = newValue
            generateHapticFeedback()
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
