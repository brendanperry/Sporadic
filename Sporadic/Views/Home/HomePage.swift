//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import CloudKit

struct HomePage: View {
    @ObservedObject var viewModel = HomeViewModel(cloudKitHelper: CloudKitHelper.shared, notificationHelper: NotificationHelper(cloudKitHelper: CloudKitHelper.shared))
    @ObservedObject var env = GlobalSettings.Env
//    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var viewRouter: ViewRouter
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 20)!]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 30)!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("Header"))]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("BackgroundImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Welcome()
                            .padding(.bottom)
                        if env.showWarning {
                            WarningMessage(viewModel: viewModel)
                        }
                        
                        Challenges(challenges: [
                            Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 12, endTime: Date(), startTime: Date(), isCompleted: false),
                            Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 9, endTime: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(), startTime: Date(), isCompleted: false),
                            Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 5, endTime: Date(), startTime: Date(), isCompleted: true)
                        ])
                        .padding(.bottom)
                        
                        GroupList(groups: [
                            UserGroup(activities: [], challenges: [], daysOfTheWeek: [], deliveryTime: Date(), emoji: "🥑", backgroundColor: .green, name: "Avacado Hoes", users: []),
                            UserGroup(activities: [], challenges: [], daysOfTheWeek: [], deliveryTime: Date(), emoji: "😘", backgroundColor: .blue, name: "Your mom's a hoe", users: []),
                            UserGroup(activities: [], challenges: [], daysOfTheWeek: [], deliveryTime: Date(), emoji: "🧔🏿‍♀️", backgroundColor: .red, name: "Come to the dark side", users: [])
                        ])
                        
                        Spacer()
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 100, height: 100, alignment: .bottom)
                    }
                }
                .padding(.top)
                
                NavigationBar(viewRouter: viewRouter)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .onAppear {
            //            GlobalSettings.Env.updateStatus()
        }
        .task {
            await viewModel.getUser()
            await viewModel.getChallenges()
            await viewModel.getGroups()
        }
//        .onChange(of: scenePhase) { newPhase in
//            if newPhase == .active {
//                //                GlobalSettings.Env.scheduleNotificationsIfNoneExist()
//
//                UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
//                    for notification in notifications {
//                        print("NOT: \(notification)")
//                    }
//                }
//            }
//        }
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
                
                textHelper.GetTextByType(key: "NoChallengesScheduled", alignment: .leading, type: .challengeAndSettings)
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
                    
                    textHelper.GetTextByType(key: "SomethingIsWrong", alignment: .leading, type: .activityTitle)
                        .padding()
                    
                    textHelper.GetTextByType(key: "Activities", alignment: .leading, type: .h3)
                        .padding([.leading])
                    
                    //                        if viewModel.getActivityCount() == 0 {
                    //                            textHelper.GetTextByType(key: "NoActivities", alignment: .leading, type: .body)
                    //                                .padding()
                    //                        } else {
                    //                            textHelper.GetTextByType(key: "SomeActivities", alignment: .leading, type: .body)
                    //                                .padding()
                    //                        }
                    
                    textHelper.GetTextByType(key: "Notifications", alignment: .leading, type: .h3)
                        .padding([.leading])
                    
                    if let authorized = notificationsAuthorized {
                        if authorized {
                            textHelper.GetTextByType(key: "NotificationsEnabled", alignment: .leading, type: .body)
                                .padding()
                        } else {
                            textHelper.GetTextByType(key: "NotificationsDisabled", alignment: .leading, type: .body)
                                .padding()
                        }
                    } else {
                        textHelper.GetTextByType(key: "Loading", alignment: .leading, type: .body)
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
        HStack {
            VStack {
                textHelper.GetTextByType(key: "WelcomeBack", alignment: .leading, type: .body, suffix: "Brendan.")
                textHelper.GetTextByType(key: "YourGoal", alignment: .leading, type: .h1)
            }
            
            Image("nic")
                .resizable()
                .frame(width: 50, height: 50, alignment: .trailing)
                .cornerRadius(100)
                .padding()
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 50)
    }
}

struct Streak: View {
    @AppStorage(UserPrefs.streak.rawValue)
    var streak = 0
    
    var textHelper = TextHelper()
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "CurrentRhythm", alignment: .leading, type: .h4)
            textHelper.GetTextByType(key: "", alignment: .leading, type: .activityTitle, prefix: "\(streak) ", suffix: streak == 1 ? Localize.getString("day") : Localize.getString("days"))
        }
        .padding()
    }
}
