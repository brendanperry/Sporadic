//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI

struct HomePage: View {
    @Binding var isAdding: Bool
    
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
                    ActivitiesHome(isAdding: $isAdding)
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
    @ObservedObject var viewModel = HomeViewModel(dataHelper: DataHelper())
    
    @State var showCompletedPage = false
    
    var body: some View {
        VStack {
            ZStack {
                Image("GoalButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 325)
                
                HStack (spacing: 30) {
                    Button(action: {
                        if let challenge = viewModel.challenge {
                            challenge.isCompleted = true
                            viewModel.saveChallenge()
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        
                            showCompletedPage = true
                        }
                    }, label: {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 5)
                            .frame(width: 40, height: 40, alignment: .center)
                            .background(viewModel.challenge?.isCompleted == true ? Circle().fill(Color.green) : Circle().fill(Color(UIColor.lightGray)))
                    })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .disabled(viewModel.challenge?.isCompleted ?? false)
                    
                    if let challenge = viewModel.challenge {
                        Text("\(challenge.oneChallengeToOneActivity?.name ?? "Activity") \(challenge.total.removeZerosFromEnd()) \(challenge.oneChallengeToOneActivity?.unit ?? "miles")")
                            .font(Font.custom("Gilroy", size: 32, relativeTo: .title2))
                    } else {
                        Text("No Challenge")
                            .font(Font.custom("Gilroy", size: 32, relativeTo: .title2))
                    }
                }
                .offset(y: -7)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fullScreenCover(isPresented: $showCompletedPage) {
                if let challenge = viewModel.challenge {
                    Complete(challenge: challenge)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private struct ButtonPressAnimationStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        }
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
