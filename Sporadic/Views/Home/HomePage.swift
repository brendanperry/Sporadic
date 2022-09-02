//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import CloudKit

struct HomePage: View {
    @ObservedObject var viewModel = HomeViewModel(cloudKitHelper: CloudKitHelper.shared)
    @ObservedObject var env = GlobalSettings.Env
//    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var viewRouter: ViewRouter
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 30)!]
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
                    PullToRefresh(coordinateSpaceName: "HomePage") {
                        viewModel.loadData(forceSync: true)
                    }
                    
                    VStack(spacing: 35) {
                        if !viewModel.areGroupsLoading && !viewModel.isUserLoading && !viewModel.areChallengesLoading {
                            Welcome(viewModel: viewModel)
                            
                            if env.showWarning {
                                WarningMessage(viewModel: viewModel)
                            }
                        
                            Challenges(challenges: viewModel.challenges)
                            
                            switch viewModel.loadingStatus {
                            case .loaded:
                                GroupList(groups: viewModel.groups, isLoading: false) { forceReload in
                                    viewModel.loadData(forceSync: forceReload)
                                }
                            case .loading:
                                GroupList(groups: viewModel.groups, isLoading: true) { forceReload in
                                    viewModel.loadData(forceSync: forceReload)
                                }
                            case .failed:
                                Text("Failed to load groups. Please try again.")
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.top)
                .coordinateSpace(name: "HomePage")
                
                NavigationBar(viewRouter: viewRouter)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
//        .onAppear {
//            //            GlobalSettings.Env.updateStatus()
//            Task {
//                await viewModel.getChallenges()
//                await viewModel.getGroups()
//            }
//        }
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
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .leading)
                    .offset(y: -1)
                    .foregroundColor(.red)
                    .padding(.leading)
                
                TextHelper.text(key: "NoChallengesScheduled", alignment: .leading, type: .challengeAndSettings)
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
                    
                    TextHelper.text(key: "SomethingIsWrong", alignment: .leading, type: .activityTitle)
                        .padding()
                    
                    TextHelper.text(key: "Activities", alignment: .leading, type: .h3)
                        .padding([.leading])
                    
                    //                        if viewModel.getActivityCount() == 0 {
                    //                            textHelper.GetTextByType(key: "NoActivities", alignment: .leading, type: .body)
                    //                                .padding()
                    //                        } else {
                    //                            textHelper.GetTextByType(key: "SomeActivities", alignment: .leading, type: .body)
                    //                                .padding()
                    //                        }
                    
                    TextHelper.text(key: "Notifications", alignment: .leading, type: .h3)
                        .padding([.leading])
                    
                    if let authorized = notificationsAuthorized {
                        if authorized {
                            TextHelper.text(key: "NotificationsEnabled", alignment: .leading, type: .body)
                                .padding()
                        } else {
                            TextHelper.text(key: "NotificationsDisabled", alignment: .leading, type: .body)
                                .padding()
                        }
                    } else {
                        TextHelper.text(key: "Loading", alignment: .leading, type: .body)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct Welcome: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            VStack {
                TextHelper.text(key: "WelcomeBack", alignment: .leading, type: .body, suffix: viewModel.user.name + ".")
                TextHelper.text(key: "YourGoal", alignment: .leading, type: .h1)
            }
            
            Image(uiImage: viewModel.user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60, alignment: .trailing)
                .cornerRadius(100)
                .padding()
        }
        .padding(.horizontal)
        .padding(.top, 50)
    }
}

struct Streak: View {
    @AppStorage(UserPrefs.streak.rawValue)
    var streak = 0
    
    var textHelper = TextHelper()
    
    var body: some View {
        VStack {
            TextHelper.text(key: "CurrentRhythm", alignment: .leading, type: .h4)
            TextHelper.text(key: "", alignment: .leading, type: .activityTitle, prefix: "\(streak) ", suffix: streak == 1 ? Localize.getString("day") : Localize.getString("days"))
        }
        .padding()
    }
}
