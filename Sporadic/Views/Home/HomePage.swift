//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack {
                    Welcome()
                    ChallengeButton()
                    Streak()
                    ActivitiesHome()
                    Spacer()
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 100, height: 100, alignment: .bottom)
                }
            })
            .padding(.top)
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
    }
}

struct Welcome: View {
    let textHelper = TextHelper()
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(text: Localize.getString("WelcomeBack"), isCentered: false, type: TextType.medium)
            textHelper.GetTextByType(text: Localize.getString("YourGoal"), isCentered: false, type: TextType.largeTitle)
        }
        .padding(.horizontal)
        .padding(.top, 50)
        .padding(.bottom)
    }
}

struct ChallengeButton: View {
    @State private var activityCompleted = false

    var body: some View {
        VStack {
            Button(action: {
                print("done")

                activityCompleted = true
            }) {
                ZStack {
                    Image("GoalButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 325)
                    HStack {
//                        Checkmark(size: 30, isOn: activityCompleted, activity: <#Activity#>, viewModel: viewModel)
                        Text("Run 3 miles")
                            .font(Font.custom("Gilroy", size: 32, relativeTo: .title))
                    }
                    .offset(y: -7)
                }

            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .disabled(activityCompleted)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct Streak: View {
    @AppStorage(UserPrefs.streak.rawValue)
    var streak = 0
    
    var textHelper = TextHelper()

    var body: some View {
        VStack {
            textHelper.GetTextByType(text: Localize.getString("CurrentRhythm"), isCentered: false, type: .medium)
            textHelper.GetTextByType(text: Localize.getString(self.getStreakText()), isCentered: false, type: .largeTitle)
        }
        .padding()
    }

    func getStreakText() -> String {
        return streak == 1 ? "1 day" : "\(streak) days"
    }
}
