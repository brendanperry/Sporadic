//
//  Challenges.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import SwiftUI
import CloudKit
import ConfettiSwiftUI

struct Challenges: View {
    @Binding var challenges: [Challenge]
    let isLoading: Bool
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Challenges", alignment: .leading, type: .h2, color: .primary)
                .padding(.horizontal)
            
            VStack {
                if isLoading && challenges.isEmpty {
                    ChallengeLoading()
                }
                else {
                    if challenges.isEmpty {
                        TextHelper.text(key: "No challenges yet today!", alignment: .center, type: .body)
                            .padding(.top)
                    }
                    else {
                        ForEach($challenges) { challenge in
                            ChallengeView(challenge: challenge, showNavigationCarrot: false)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct ChallengeLoading: View {
    @State var isAnimating = false
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 35, alignment: .center)
                .padding(.trailing, 5)
            
            LoadingBar()
                .frame(height: 20)
        }
        .padding()
        .frame(height: 75, alignment: .center)
        .background(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct ChallengeView: View {
    @Binding var challenge: Challenge
    @State var showError = false
    @State var confetti = 0
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
        .alert(isPresented: $showError) {
            Alert(title: Text("Connection Failed"), message: Text("Could not complete exercise."))
        }
    }
    
    func inProgressCheckbox() -> some View {
        Button(action: {
            let status = challenge.getStatus()
            
            if status == .inProgress {
                challenge.isCompleted = true
                confetti += 1
            }
            
            CloudKitHelper.shared.completeChallenge(challenge: challenge) { error in
                if let error = error {
                    print(error)
                    showError = true
                    challenge.isCompleted = false
                }
            }
        }, label: {
            Image("Unmarked Challenge Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 35, height: 35, alignment: .center)
        })
        .padding(.trailing, 5)
        .confettiCannon(counter: $confetti, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 15), radius: 300)
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
