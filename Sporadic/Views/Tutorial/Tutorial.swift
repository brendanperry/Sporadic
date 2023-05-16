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
            case 4:
                fifthPage()
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
        ZStack {
                Image("TutorialBackground1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding()
                
            TextHelper.text(key: "StayActive", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "Receive random exercise challenges throughout your week, personalized to you.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func secondPage() -> some View {
        VStack {
            Image("TutorialBackground1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding()
            
            TextHelper.text(key: "Get started 🚀", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "You will be challenged with exercises from your group. Each exercise has a difficulty range the challenge will be chosen from.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func thirdPage() -> some View {
        VStack {
            Image("TutorialBackground1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding()
            
            VStack {
                HStack(spacing: -10) {
                    Circle()
                        .frame(width: 21)
                        .foregroundColor(Color("SuccessButtons"))
//                        .opacity(<#T##opacity: Double##Double#>)
                        .border(Color.white, width: 5)
                        .zIndex(3)
                    Circle()
//                    rgba(217, 217, 217, 0.5)
                        .frame(width: 21)
                        .foregroundColor(.gray)
                        .opacity(0.50)
                        .zIndex(2)
                    Circle()
                        .frame(width: 21)
                        .foregroundColor(.gray)
                        .opacity(0.25)
                        .zIndex(1)
                }
            }
            
            TextHelper.text(key: "Pick a preset", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "We want to help you get started. You can fully customize this group afterwards.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func fourthPage() -> some View {
        VStack {
            Image("TutorialBackground1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding()
            
            TextHelper.text(key: "Introduce yourself", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "There’s no account required. A name and photo will help your friends recognize you.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func fifthPage() -> some View {
        VStack {
            Image("TutorialBackground1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding()
            
            TextHelper.text(key: "Complete challenges with friends", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "Invite your friends and complete challenges together! Or go solo and rock it out.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial(selection: 2)
    }
}
