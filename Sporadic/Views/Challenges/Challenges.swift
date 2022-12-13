//
//  Challenges.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import SwiftUI
import CloudKit

struct Challenges: View {
    let challenges: [Challenge]
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Challenges", alignment: .leading, type: .h2, color: .primary)
                .padding(.horizontal)
            
            VStack {
                ForEach(challenges) { challenge in
                    NavigationLink(destination: ChallengeDetail(challenge: challenge)) {
                        ChallengeView(challenge: challenge, showNavigationCarrot: true)
                    }
                    .buttonStyle(ButtonPressAnimationStyle())
                }
                
                Spacer()
            }
        }
    }
}

struct ChallengeView: View {
    let challenge: Challenge
    let showNavigationCarrot: Bool
    
    var body: some View {
        HStack {
            switch challenge.getStatus() {
            case .inProgress:
                inProgressCheckbox()
                
                VStack {
                    TextHelper.text(key: "\(challenge.activity?.name ?? "") \(challenge.amount) \(challenge.activity?.unit.rawValue ?? "miles")", alignment: .leading, type: .challengeAndSettings, color: .white)
                    TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .challengeGroup)
                }
            case .completed:
                completedCheckbox()
                
                VStack {
                    TextHelper.text(key: "ChallengeCompleted", alignment: .leading, type: .challengeAndSettings, color: .white)
                    TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .challengeGroup)
                }
            case .failed:
                failedCheckbox()
                
                VStack {
                    TextHelper.text(key: "ChallengeFailed", alignment: .leading, type: .challengeAndSettings, color: .white)
                    TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .challengeGroup)
                }
            }
            
            if showNavigationCarrot {
                Image("View Group Carrot Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15, alignment: .center)
                    .foregroundColor(.white)
            }
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
