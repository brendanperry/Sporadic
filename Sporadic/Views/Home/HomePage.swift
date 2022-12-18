//
//  HomePage.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import CloudKit



struct HomePage: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var viewRouter: ViewRouter
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
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
                        Welcome(viewModel: viewModel)
                    
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
                .shadow(radius: 3)
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
