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
            textHelper.GetTextByType(key: "Challenges", alignment: .leading, type: .smallBold, color: .black)
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
                    textHelper.GetTextByType(key: "Run 3 Miles", alignment: .leading, type: .largeBody, color: .white)
                    textHelper.GetTextByType(key: "You're trash", alignment: .leading, type: .small)
                }
            case .completed:
                completedCheckbox()
                
                VStack {
                    textHelper.GetTextByType(key: "ChallengeCompleted", alignment: .leading, type: .largeBody, color: .white)
                    textHelper.GetTextByType(key: "You're trash", alignment: .leading, type: .small)
                }
            case .failed:
                failedCheckbox()
                
                VStack {
                    textHelper.GetTextByType(key: "ChallengeFailed", alignment: .leading, type: .largeBody, color: .white)
                    textHelper.GetTextByType(key: "Avacado Hoes", alignment: .leading, type: .small)
                }
            }
            
            Image(systemName: "chevron.forward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15, alignment: .center)
                .foregroundColor(Color(uiColor: UIColor.lightGray))
        }
        .padding()
        .frame(height: 75, alignment: .center)
        .background(Color.blue)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.top, 5)
    }
    
    func inProgressCheckbox() -> some View {
        Button(action: {
            print("COMPLETE")
        }, label: {
            Circle()
                .stroke(lineWidth: 7)
                .foregroundColor(.purple)
                .frame(width: 23, height: 23, alignment: .center)
        })
        .padding(.trailing, 5)
    }
    
    func completedCheckbox() -> some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.green)
            
            Image(systemName: "checkmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 15, height: 15, alignment: .center)
        }
        .padding(.trailing, 5)
    }
    
    func failedCheckbox() -> some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.red)
            
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 15, height: 15, alignment: .center)
        }
        .padding(.trailing, 5)
    }
    
    func getImage(challengeStatus: ChallengeStatus) -> String {
        switch challengeStatus {
        case .completed:
            return "checkmark"
        case .failed:
            return "xmark"
        case .inProgress:
            return ""
        }
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
