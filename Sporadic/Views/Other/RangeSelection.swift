//
//  RangeSelection.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/16/23.
//

import SwiftUI
import RangeSlider

struct RangeSelection: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let unit: ActivityUnit
    let viewModel: AddActivityViewModel
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Difficulty range", alignment: .leading, type: .h4)
            
            VStack {
                
                ZStack {
                    HStack {
                        HStack(alignment: .bottom, spacing: 1) {
                            Text(minValue.removeZerosFromEnd())
                                .font(Font.custom("Lexend-SemiBold", size: 17))
                            Text(unit.toAbbreviatedString())
                                .font(Font.custom("Lexend-SemiBold", size: 12.5))
                                .offset(y: -1)
                        }
                        .padding(.leading, 50)
                        
                        Spacer()
                        
                        HStack(alignment: .bottom, spacing: 1) {
                            Text(maxValue.removeZerosFromEnd())
                                .font(Font.custom("Lexend-SemiBold", size: 17))
                            Text(unit.toAbbreviatedString())
                                .font(Font.custom("Lexend-SemiBold", size: 12.5))
                                .offset(y: -1)
                        }
                        .padding(.trailing, 50)
                    }
                    
                    TextHelper.text(key: "-", alignment: .center, type: .h2)
                }
                
                RangeSlider(
                    lineHeight: 13,
                    lineWidth: UIScreen.main.bounds.width - 100,
                    lineCornerRadius: 16,
                    circleWidth: 35,
                    circleShadowRadius: 1,
                    minValue: unit.minValue(),
                    maxValue: unit.maxValue(),
                    circleBorder: 10,
                    leftCircleBorderColor: Color("Gradient1"),
                    rightCircleBorderColor: Color("Gradient2"),
                    leftCircleColor: Color.white,
                    rightCircleColor: Color.white,
                    lineColorInRange: AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing)),
                    lineColorOutOfRange: Color("RangeUnselected"),
                    shadow: Color("Shadow"),
                    leftValue: $minValue,
                    rightValue: $maxValue,
                    unitPublisher: viewModel.unitPublisher.eraseToAnyPublisher())
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        }
    }
}
