//
//  ReviewPrompt.swift
//  Sporadic
//
//  Created by Brendan Perry on 2/1/25.
//

import SwiftUI
import Aptabase

struct ReviewPrompt: View {
    @Environment(\.requestReview) var requestReview
    @Binding var showReviewPrompt: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Memojis()
                
                VStack {
                    TextHelper.text(key: "Support Us!", alignment: .center, type: .h1)
                        .padding(.bottom)
                    
                    TextHelper.text(key: "We are a team of 2 brothers who created this app to help us get active. If you are enjoying Sporadic, have any feedback, or have ideas for new features, then leave us a review to support our work. It helps a lot!", alignment: .center, type: .body)
                    
                    HStack {
                        Button(action: {
                            Aptabase.shared.trackEvent("soft_review_response", with: ["show_review_prompt": false])
                            withAnimation {
                                showReviewPrompt = false
                            }
                        }, label: {
                            TextHelper.text(key: "Maybe Later", alignment: .center, type: .h5, color: Color("CancelText"))
                                .padding()
                                .background(Color("Cancel"))
                                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                        
                        Spacer()
                        
                        Button(action: {
                            Aptabase.shared.trackEvent("soft_review_response", with: ["show_review_prompt": true])
                            requestReview()
                            withAnimation {
                                showReviewPrompt = false
                            }
                        }, label: {
                            TextHelper.text(key: "Leave a Review", alignment: .center, type: .h5, color: .white)
                                .padding()
                                .background(Color("BrandPurple"))
                                .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                    }
                    .padding(.top)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundStyle(Color("Panel"))
                        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom))
            }
        }
    }
}

#Preview {
    ReviewPrompt(showReviewPrompt: .constant(true))
}
