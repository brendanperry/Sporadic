//
//  Challenges.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import SwiftUI
import CloudKit

struct Challenges: View {
    let textHelper = TextHelper()
    let challenges: [Challenge]
    
    var body: some View {
        VStack {
            textHelper.GetTextByType(key: "Challenges", alignment: .leading, type: .h2, color: .primary)
                .padding(.horizontal)
            
            VStack {
                ForEach(challenges) { challenge in
                    NavigationLink(destination: Text("Challenge")) {
                        ChallengeView(challenge: challenge)
                    }
                    .buttonStyle(ButtonPressAnimationStyle())
                }
            }
        }
    }
}

struct ChallengeView: View {
    let textHelper = TextHelper()
    let challenge: Challenge
    
    var body: some View {
        HStack {
            switch challenge.getStatus() {
            case .inProgress:
                inProgressCheckbox()
                
                VStack {
                    textHelper.GetTextByType(key: "Run 3 Miles", alignment: .leading, type: .challengeAndSettings, color: .white)
                    textHelper.GetTextByType(key: "You're trash", alignment: .leading, type: .challengeGroup)
                }
            case .completed:
                completedCheckbox()
                
                VStack {
                    textHelper.GetTextByType(key: "ChallengeCompleted", alignment: .leading, type: .challengeAndSettings, color: .white)
                    textHelper.GetTextByType(key: "You're trash", alignment: .leading, type: .challengeGroup)
                }
            case .failed:
                failedCheckbox()
                
                VStack {
                    textHelper.GetTextByType(key: "ChallengeFailed", alignment: .leading, type: .challengeAndSettings, color: .white)
                    textHelper.GetTextByType(key: "Avacado Hoes", alignment: .leading, type: .challengeGroup)
                }
            }
            
            Image("View Group Carrot Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15, alignment: .center)
                .foregroundColor(.white)
        }
        .padding()
        .frame(height: 75, alignment: .center)
        .background(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.top, 5)
    }
    
    func inProgressCheckbox() -> some View {
        Button(action: {
            print("COMPLETE")
        }, label: {
            Image("Unmarked Challenge Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 35, height: 35, alignment: .center)
        })
        .padding(.trailing, 5)
    }
    
    func completedCheckbox() -> some View {
        Image("Completed Challenge Icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 35, height: 35, alignment: .center)
            .padding(.trailing, 5)
    }
    
    func failedCheckbox() -> some View {
        Image("Failed Challenge Icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 35, height: 35, alignment: .center)
            .padding(.trailing, 5)
    }
}

struct Challenges_Previews: PreviewProvider {
    static var previews: some View {
        Challenges(challenges: [
            Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 12, endTime: Date(), startTime: Date(), isCompleted: false),
            Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 9, endTime: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(), startTime: Date(), isCompleted: false),
            Challenge(id: UUID(), activity: CKRecord.Reference(record: CKRecord(recordType: "Challenge"), action: .deleteSelf), amount: 5, endTime: Date(), startTime: Date(), isCompleted: true)
        ])
    }
}
