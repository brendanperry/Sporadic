//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI

struct HomePage: View {
    @Binding var isAdding: Bool
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var env = GlobalSettings.Env
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack {
                    Welcome()
                    ChallengeButton(viewModel: viewModel)
                    
                    if env.showWarning {
                        WarningMessage(viewModel: viewModel)
                    }
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
        .onAppear {
            GlobalSettings.Env.updateStatus()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                GlobalSettings.Env.scheduleNotificationsIfNoneExist()
                
                UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                    for notification in notifications {
                        print("NOT: \(notification)")
                    }
                }
            }
        }
    }
}

struct WarningMessage: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var showInvalidSettingsPopUp = false
    @State var notificationsAuthorized: Bool?
    let textHelper = TextHelper()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .leading)
                    .offset(y: -1)
                    .foregroundColor(.red)
                    .padding(.leading)
                
                textHelper.GetTextByType(text: Localize.getString("NoChallengesScheduled"), isCentered: false, type: .medium)
                    .padding([.top, .bottom])
            }
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                showInvalidSettingsPopUp = true
                
                viewModel.getNotificationStatus { isAuthorized in
                    notificationsAuthorized = isAuthorized
                }
            }, label: {
                Text("Schedule")
                    .frame(minWidth: 60)
                    .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
                    .foregroundColor(Color("SettingButtonTextColor"))
                    .padding(12)
                    .background(Color("SettingsButtonBackgroundColor"))
                    .cornerRadius(10)
            })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .bottom])
                .buttonStyle(ButtonPressAnimationStyle())
                .fullScreenCover(isPresented: $showInvalidSettingsPopUp) {
                    VStack {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            
                            showInvalidSettingsPopUp = false
                        }) {
                            Image("CloseButton")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .buttonStyle(ButtonPressAnimationStyle())
                        
                        textHelper.GetTextByType(text: Localize.getString("SomethingIsWrong"), isCentered: false, type: .largeTitle)
                            .padding()
                        
                        textHelper.GetTextByType(text: Localize.getString("Activities"), isCentered: false, type: .medium)
                            .padding([.leading])
                        
                        if viewModel.getActivityCount() == 0 {
                            textHelper.GetTextByType(text: Localize.getString("NoActivities"), isCentered: false, type: .body)
                                .padding()
                        } else {
                            textHelper.GetTextByType(text: Localize.getString("SomeActivities"), isCentered: false, type: .body)
                                .padding()
                        }
                        
                        textHelper.GetTextByType(text: Localize.getString("Notifications"), isCentered: false, type: .medium)
                            .padding([.leading])
                        
                        if let authorized = notificationsAuthorized {
                            if authorized {
                                textHelper.GetTextByType(text: Localize.getString("NotificationsEnabled"), isCentered: false, type: .body)
                                    .padding()
                            } else {
                                textHelper.GetTextByType(text: Localize.getString("NotificationsDisabled"), isCentered: false, type: .body)
                                    .padding()
                            }
                        } else {
                            textHelper.GetTextByType(text: Localize.getString("Loading"), isCentered: false, type: .body)
                                .padding()
                        }

                        Spacer()
                    }
                }
        }
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
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var env = GlobalSettings.Env
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
                        if let challenge = env.currentChallenge {
                            challenge.isCompleted = true
                            viewModel.completeChallenge()
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        
                            showCompletedPage = true
                        }
                    }, label: {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 5)
                            .frame(width: 40, height: 40, alignment: .center)
                            .background(env.currentChallenge?.isCompleted == true ? Circle().fill(Color.green) : Circle().fill(Color(UIColor.lightGray)))
                    })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .disabled(env.currentChallenge?.isCompleted ?? false)
                    
                    if let challenge = env.currentChallenge {
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
                if let challenge = env.currentChallenge {
                    Complete(challenge: challenge)
                }
            }
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
