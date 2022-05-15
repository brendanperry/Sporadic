//
//  Tutorial.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/14/22.
//

import SwiftUI

struct Tutorial: View {
    @State var selection = 0
    @AppStorage(UserPrefs.daysPerWeek.rawValue)
    var days = 3.0
    let textHelper = TextHelper()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .zIndex(-1)

            switch selection {
            case 1:
                secondPage()
            case 2:
                thirdPage()
            case 3:
                fourthPage()
            default:
                firstPage()
            }
            
            VStack {
                Button(action: {
                    withAnimation {
                        if selection == 3 {
                            selection = 0
                        } else {
                            selection += 1
                        }
                    }
                }, label: {
                    Image(selection == 0 ? "Landing-Arrow-White" : "Landing-Arrow-Blue")
                        .resizable()
                        .frame(width: 60, height: 60, alignment: .center)
                })
                .buttonStyle(ButtonPressAnimationStyle())
                
                HStack {
                    Capsule()
                        .frame(width: selection == 0 ? 20 : 10, height: 10, alignment: .leading)
                    Capsule()
                        .frame(width: selection == 1 ? 20 : 10, height: 10, alignment: .center)
                    Capsule()
                        .frame(width: selection == 2 ? 20 : 10, height: 10, alignment: .center)
                    Capsule()
                        .frame(width: selection == 3 ? 20 : 10, height: 10, alignment: .center)
                }
                .padding()
                .foregroundColor(selection == 0 ? .white : .blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    func firstPage() -> some View {
        VStack {
            Image("landing-rotation")
                .resizable()
                .frame(height: 350, alignment: .leading)
            textHelper.GetTextByType(key: "StayActive", alignment: .leading, type: .title, color: .white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.blue)
        .transition(.backslide)
    }
    
    func secondPage() -> some View {
        VStack(spacing: 0) {
            Image("Landing-Image1")
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.top)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, -45)
                .background(Color.blue)
            textHelper.GetTextByType(key: "GetNotifications", alignment: .leading, type: .title)
                .padding()
                .background(Color.red)
            textHelper.GetTextByType(key: "SetDays", alignment: .leading, type: .body)
                .padding()
            CustomSlider(lineHeight: 12,
                         lineWidth: UIScreen.main.bounds.width - 50,
                         lineCornerRadius: 10,
                         circleWidth: 30,
                         circleShadowRadius: 5,
                         roundToNearest: 1,
                         minValue: 1,
                         maxValue: 7,
                         circleBorder: 4,
                         circleBorderColor: .white,
                         circleColor: .white,
                         lineColorInRange: Color("ActivityRangeColor"),
                         lineColorOutOfRange: Color("SliderBackground"),
                         selection: $days)
            .frame(maxWidth: .infinity, maxHeight: 10, alignment: .center)
            
            HStack {
                textHelper.GetTextByType(key: "1", alignment: .leading, type: .medium)
                    .padding(.leading)

                textHelper.GetTextByType(key: "7", alignment: .trailing, type: .medium)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func thirdPage() -> some View {
        VStack {
            Image("Landing-Image2")
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.top)
                .frame(maxWidth: .infinity, alignment: .top)
            textHelper.GetTextByType(key: "ScheduleChallenges", alignment: .leading, type: .title)
                .padding()
            textHelper.GetTextByType(key: "SetTime", alignment: .leading, type: .body)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func fourthPage() -> some View {
        VStack {
            textHelper.GetTextByType(key: "ChooseActivities", alignment: .leading, type: .title)
                .padding()
            textHelper.GetTextByType(key: "ChooseRange", alignment: .leading, type: .body)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }

}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial()
    }
}
