//
//  ChallengeDetail.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/8/22.
//

import SwiftUI
import CloudKit

struct ChallengeDetail: View {
    @ObservedObject var challenge: Challenge
    @Binding var showReviewPrompt: Bool
    let triggerConfetti: (UserGroup) -> Void
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 35) {
                VStack {
                    TextHelper.text(key: "CompleteYourChallenge", alignment: .leading, type: .h2)
                        .padding(.horizontal)
                    ChallengeView(challenge: challenge, showReviewPrompt: $showReviewPrompt, triggerConfetti: triggerConfetti, showNavigationCarrot: false)
                }
                .padding(.top, 50)
                
                UsersForChallenge(users: challenge.users ?? [])
                
                Spacer()
            }
        }
    }
    
    struct UsersForChallenge: View {
        let users: [User]
        
        init(users: [User]) {
            self.users = users
            
            UITableView.appearance().backgroundColor = .clear
        }
        
        var body: some View {
            VStack {
                TextHelper.text(key: "PeopleInGroup", alignment: .leading, type: .h2)
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        if users.isEmpty {
                            HStack {
                                Circle()
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .foregroundColor(Color.gray)
                                    .cornerRadius(.infinity)
                                
                                LoadingBar()
                                    .frame(height: 20)
                            }
                            .padding()
                        }
                        else {
                            ForEach(users) { user in
                                HStack {
                                    Image(uiImage: user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .cornerRadius(.infinity)
                                    
                                    VStack {
                                        TextHelper.text(key: user.name, alignment: .leading, type: .h2)
                                        TextHelper.text(key: "NotCompleted", alignment: .leading, type: .h4)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 250)
                .background(Color("Panel"))
                .cornerRadius(16)
            }
            .padding(.horizontal)
        }
    }
}
