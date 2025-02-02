//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import CloudKit
import ConfettiSwiftUI

struct HomePage: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var showReviewPrompt: Bool
    @EnvironmentObject var viewRouter: ViewRouter
    @State var showProPopUp = false
    @EnvironmentObject var storeManager: StoreManager
    @AppStorage("GroupHint") var showGroupHint = true
    
    init(viewModel: HomeViewModel, showReviewPrompt: Binding<Bool>) {
        self.viewModel = viewModel
        self._showReviewPrompt = showReviewPrompt
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 30)!]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 30)!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("Gray300"))]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("BackgroundImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 35) {
                            Welcome(viewModel: viewModel)
                            
                            VStack {
                                Challenges(challenges: viewModel.challenges, isLoading: viewModel.areChallengesLoading, showReviewPrompt: $showReviewPrompt) { group in
                                    viewModel.triggerConfetti(group: group)
                                }
                                
                                if !viewModel.areChallengesLoading {
                                    HStack {
                                        Image("ChallengeStatus")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 35, height: 35, alignment: .center)
                                            .padding(.trailing, 5)
                                        
                                        Text(.init(viewModel.nextChallengeText))
                                            .font(Font.custom("Lexend-Regular", size: 15, relativeTo: .body))
                                            .foregroundColor(Color("Gray400AutoTheme"))
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius).stroke(Color("NextChallengeBG")))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                }
                            }
                            
                            GroupList(groups: $viewModel.groups, isLoading: viewModel.areGroupsLoading, updateNextChallengeText: {
                                viewModel.loadNextChallengeText()
                            }, hardRefresh: {
                                viewModel.getGroups()
                            })
                            
                            if showGroupHint && UserDefaults.standard.integer(forKey: "ChallengesCompleted") == 0 {
                                InfoBubble(text: "We've set up a group for you to get started. Groups consist of exercises and friends that you invite. You can edit your group by tapping on it or create a new one by hitting the plus button.") {
                                    withAnimation {
                                        showGroupHint = false
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 100)
                        .onAppear {
                            GlobalSettings.shared.swipeToGoBackEnabled = true
                        }
                    }
                    .padding(.top, 1)
                    .refreshable {
                        viewModel.loadData()
                    }
                }
                
                ConfettiBar(confetti: $viewModel.confetti)
                
                NavigationBar(viewRouter: viewRouter)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .popover(isPresented: $showProPopUp) {
            Paywall(shouldShow: $showProPopUp)
        }
        .onChange(of: showProPopUp) { newValue in
            if newValue == false {
                viewModel.loadData()
            }
        }
        .task {
            let isPro = await storeManager.hasPaidAccount()
            if UserDefaults.standard.bool(forKey: "hasCompletedSetup") == false && !isPro {
                showProPopUp = true
                UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
            }
        }
    }
}

struct ConfettiBar: View {
    @Binding var confetti: Int
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 1, height: 1)
                    .foregroundColor(.clear)
                    .confettiCannon(counter: $confetti, num: 100, rainHeight: 1250, fadesOut: false, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 180))
                    .offset(y: -25)
                Spacer()
            }
            
            Spacer()
        }
    }
}

struct Welcome: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            VStack {
                if viewModel.user.name != "" {
                    TextHelper.text(key: "WelcomeBack", alignment: .leading, type: .body, suffix: viewModel.user.name + ".")
                }
                else {
                    TextHelper.text(key: "", alignment: .leading, type: .body)
                }
                
                TextHelper.text(key: "YourGoal", alignment: .leading, type: .h1)
            }
            
            Image(uiImage: viewModel.user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60, alignment: .center)
                .cornerRadius(100)
        }
        .padding(.top, 30)
        .padding(.horizontal)
    }
}

struct Streak: View {
    @AppStorage(UserPrefs.streak.rawValue)
    var streak = 0
    
    var textHelper = TextHelper()
    
    var body: some View {
        VStack {
            TextHelper.text(key: "CurrentRhythm", alignment: .leading, type: .h4)
            TextHelper.text(key: "", alignment: .leading, type: .h2, prefix: "\(streak) ", suffix: streak == 1 ? Localize.getString("day") : Localize.getString("days"))
        }
        .padding()
    }
}
