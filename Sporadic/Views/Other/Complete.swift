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
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                dismiss()
            }) {
                Image("CloseButton")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(ButtonPressAnimationStyle())
            
            Spacer()
            
            VStack {
                textHelper.GetTextByType(key: "GreatWork", alignment: .leading, type: .largeTitle, color: nil)
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
                    
                    textHelper.GetTextByType(key: "Complete", alignment: .leading, type: .title, color: .white)
                        .offset(x: 25, y: -5)
                }
                .padding(.bottom)
                
                textHelper.GetTextByType(key: "CurrentRhythm", alignment: .leading, type: .settingsEntryTitle, color: nil)
                
                textHelper.GetTextByType(key: "days", alignment: .leading, type: .largeTitle, color: nil, prefix: "\(streak) ")
                    .padding(.bottom)
                
                textHelper.GetTextByType(key: "YourNewTotalIs", alignment: .leading, type: .settingsEntryTitle, color: nil)
//                
//                textHelper.GetTextByType(key: "", alignment: .leading, type: .largeTitle, color: Color("CheckGreen"), prefix: "\(challenge.activity?.total ?? 0) ", suffix: "\(challenge.activity?.unit ?? "miles")")
            }
            
            Spacer()
        }
        .padding()
    }
}
