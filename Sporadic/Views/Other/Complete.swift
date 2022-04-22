//
//  Complete.swift
//  Sporadic
//
//  Created by Brendan Perry on 2/12/22.
//

import SwiftUI

struct Complete: View {
    @Environment(\.dismiss) var dismiss
    
    let textHelper = TextHelper()
    let streak = UserDefaults.standard.integer(forKey: UserPrefs.streak.rawValue)
    let challenge: Challenge
    
    var body: some View {
        VStack {
            Button(action: {
                dismiss()
            }) {
                Image("CloseButton")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack {
                textHelper.GetTextByType(text: "Great work!", isCentered: true, type: .largeTitle, color: nil)
                ZStack {
                    Image("GoalButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 325)
                    
                        Image("Checkmark")
                            .resizable()
                            .scaleEffect(2)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30, alignment: .leading)
                            .background {
                                Circle()
                                    .foregroundColor(Color("CheckGreen"))
                                    .frame(width: 45, height: 45, alignment: .center)
                            }
                            .offset(x: -100, y: -5)
                    
                    textHelper.GetTextByType(text: "Complete!", isCentered: true, type: .title, color: .white)
                        .offset(x: 25, y: -5)
                }
                .padding(.bottom)
                
                textHelper.GetTextByType(text: "Current Rhythm", isCentered: true, type: .settingsEntryTitle, color: nil)
                
                textHelper.GetTextByType(text: "\(streak) days", isCentered: true, type: .largeTitle, color: nil)
                    .padding(.bottom)
                
                textHelper.GetTextByType(text: "You new total is", isCentered: true, type: .settingsEntryTitle, color: nil)
                
                textHelper.GetTextByType(text: "\(challenge.oneChallengeToOneActivity?.total ?? 0) \(challenge.oneChallengeToOneActivity?.unit ?? "miles")", isCentered: true, type: .largeTitle, color: Color("CheckGreen"))
            }
            
            Spacer()
        }
        .padding()
    }
}
