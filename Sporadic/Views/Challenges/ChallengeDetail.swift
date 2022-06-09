//
//  ChallengeDetail.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/8/22.
//

import SwiftUI
import CloudKit

struct ChallengeDetail: View {
    let users = [
        User(recordId: NSObject(), name: "Brendan", photo: ""),
        User(recordId: NSObject(), name: "Brendan", photo: ""),
        User(recordId: NSObject(), name: "Brendan", photo: "")
    ]
    
    let challenge: Challenge
    
    let textHelper = TextHelper()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 35) {
                VStack {
                    textHelper.GetTextByType(key: "CompleteYourChallenge", alignment: .leading, type: .h2)
                        .padding(.horizontal)
                    ChallengeView(challenge: challenge, showNavigationCarrot: false)
                }
                .padding(.top, 50)
                
                UsersForChallenge(users: users)
                
                Spacer()
            }
        }
    }
    
    struct UsersForChallenge: View {
        let textHelper = TextHelper()
        @State var users: [User]
        
        init(users: [User]) {
            self.users = users
            
            UITableView.appearance().backgroundColor = .clear
        }
        
        var body: some View {
            VStack {
                textHelper.GetTextByType(key: "PeopleInGroup", alignment: .leading, type: .h2)
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(users) { user in
                            HStack {
                                Image("nic")
                                    .resizable()
                                    .frame(width: 50, height: 50, alignment: .leading)
                                    .cornerRadius(100)
                                
                                VStack {
                                    textHelper.GetTextByType(key: user.name, alignment: .leading, type: .h2)
                                    textHelper.GetTextByType(key: "NotCompleted", alignment: .leading, type: .challengeGroup)
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
    
    struct ChallengeDetail_Previews: PreviewProvider {
        static var previews: some View {
            ChallengeDetail(challenge: Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 5, endTime: Date(), startTime: Date(), isCompleted: true))
        }
    }
}
