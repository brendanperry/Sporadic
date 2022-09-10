//
//  ChallengeDetail.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/8/22.
//

import SwiftUI
import CloudKit

struct ChallengeDetail: View {
    let challenge: Challenge
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 35) {
                VStack {
                    TextHelper.text(key: "CompleteYourChallenge", alignment: .leading, type: .h2)
                        .padding(.horizontal)
                    ChallengeView(challenge: challenge, showNavigationCarrot: false)
                }
                .padding(.top, 50)
                
                UsersForChallenge(users: challenge.users)
                
                Spacer()
            }
        }
    }
    
    struct UsersForChallenge: View {
        @State var users: [User]
        
        init(users: [User]) {
            self.users = users
            
            UITableView.appearance().backgroundColor = .clear
        }
        
        var body: some View {
            VStack {
                TextHelper.text(key: "PeopleInGroup", alignment: .leading, type: .h2)
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(users) { user in
                            HStack {
                                Image(uiImage: user.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                                    .resizable()
                                    .frame(width: 50, height: 50, alignment: .leading)
                                    .cornerRadius(100)
                                
                                VStack {
                                    TextHelper.text(key: user.name, alignment: .leading, type: .h2)
                                    TextHelper.text(key: "NotCompleted", alignment: .leading, type: .challengeGroup)
                                }
                            }
                        }
                        .padding(12)
                    }
                }
                .frame(height: 250)
                .padding(12)
                .background(Color("Panel"))
                .cornerRadius(16)
            }
            .padding(.horizontal)
        }
    }
}
