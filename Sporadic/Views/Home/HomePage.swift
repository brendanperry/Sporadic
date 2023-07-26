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
    @EnvironmentObject var viewRouter: ViewRouter
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 30)!]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Lexend-SemiBold", size: 30)!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("Gray300"))]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("BackgroundImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer().frame(height: 1)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 35) {
                            Welcome(viewModel: viewModel)
                            
                            VStack {
                                Challenges(challenges: viewModel.challenges, isLoading: viewModel.areChallengesLoading) { group in
                                    viewModel.triggerConfetti(group: group)
                                }
                                
                                if !viewModel.areChallengesLoading {
                                    HStack {
                                        Image("ChallengeStatus")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25)
                                            .padding(.trailing)
                                        
                                        Text(.init(viewModel.nextChallengeText))
                                            .font(Font.custom("Lexend-Regular", size: 15, relativeTo: .body))
                                            .foregroundColor(Color("Gray400"))
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius).foregroundColor(Color("BrandLight")))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                }
                            }
                            
                            GroupList(groups: $viewModel.groups, isLoading: viewModel.areGroupsLoading, updateNextChallengeText: {
                                viewModel.loadNextChallengeText()
                            }, hardRefresh: {
                                viewModel.getGroups()
                            })
                        }
                        .padding(.top)
                        .padding(.bottom, 100)
                    }
                    .padding(.top)
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
                .frame(width: 60, height: 60, alignment: .trailing)
                .cornerRadius(100)
                .padding()
        }
        .padding(.top, 11)
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
