//
//  Paywall.swift
//  Sporadic
//
//  Created by brendan on 4/6/24.
//

import SwiftUI

struct Paywall: View {
    @Binding var shouldShow: Bool
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        Text("Get the most out of ")
                            .foregroundColor(Color("Gray300"))
                        + Text("Sporadic   ")
                            .foregroundColor(Color("BrandPurple"))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .font(Font.custom("Lexend-SemiBold", size: 29, relativeTo: .largeTitle))
                    .padding(.horizontal)
                    .padding(.top, 100)
                    
                    TextHelper.text(key: "Need more groups or a custom exercise? Upgrade to access these features, and to support our work.", alignment: .leading, type: .body)
                        .padding()
                    
                    VStack {
                        ZStack {
                            HStack(spacing: 22) {
                                Text("🧘‍♀️")
                                    .padding(5)
                                    .background(Circle().foregroundStyle(.blue))
                                Text("🏃")
                                    .padding(5)
                                    .background(Circle().foregroundStyle(.green))
                            }
                            
                            Text("🚴")
                                .padding(5)
                                .background(Circle().foregroundStyle(.yellow))
                                .padding(2)
                                .background(Circle().foregroundStyle(Color("Panel")))
                                .scaleEffect(1.1)
                        }
                        .padding(.vertical)
                        
                        TextHelper.text(key: "Create or join unlimited groups", alignment: .center, type: .h3)
                    }
                    .frame(height: 100)
                    .padding(.vertical)
                    .background(Color("Panel"))
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                    .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                    .padding()
                    
                    VStack {
                        ZStack {
                            Image("Custom Activity Icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius).foregroundStyle(Color("CustomExercise")).aspectRatio(1, contentMode: .fill))
                                .padding(7)
                            
                            PlusButton(shape: Circle(), backgroundColor: Color("Panel"), lockLightMode: false, shadow: true)
                                .scaleEffect(0.45)
                                .offset(x: -25, y: -25)
                        }
                        
                        TextHelper.text(key: "Create custom exercises", alignment: .center, type: .h3)
                    }
                    .frame(height: 100)
                    .padding(.vertical)
                    .background(Color("Panel"))
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                    .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
                    .padding([.horizontal, .bottom])
                    
                    Spacer()
                    
                    TextHelper.text(key: "We don't believe in subscriptions here. This is a one time payment. 🙌", alignment: .center, type: .h7)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        Task {
                            let wasSuccessful = await storeManager.purchasePro()
                            if wasSuccessful {
                                dismiss()
                            }
                        }
                    }, label: {
                        if let proUpgradeProduct = storeManager.proUpgradeProduct {
                            Text("Purchase - \(proUpgradeProduct.displayPrice)")
                                .font(Font.custom("Lexend-SemiBold", size: 16, relativeTo: .title))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                    })
                    .padding(10)
                    .background(Color("BrandPurple"))
                    .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                    .padding()
                    
                    Button(action: {
                        Task {
                            await storeManager.restore()
                        }
                    }, label: {
                        TextHelper.text(key: "Restore Purchase", alignment: .center, type: .body)
                    })
                    .padding(.bottom)
                }
            }
            
            CloseButton(shouldShow: $shouldShow)
        }
        .background(
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

#Preview {
    Paywall(shouldShow: .constant(true))
}
