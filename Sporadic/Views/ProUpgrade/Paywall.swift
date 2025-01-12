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
    
    @State var selectedProductId = "sporadic_pro"
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Get the most out of Sporadic")
                    .foregroundColor(Color("Gray300"))
                    .fixedSize(horizontal: false, vertical: true)
                    .font(Font.custom("Lexend-SemiBold", size: 29, relativeTo: .largeTitle))
                    .padding(.horizontal)
                    .padding(.top, 100)
                
                TextHelper.text(key: "Meet your fitness goals by creating custom exercises and unlimited groups with Sporadic Pro.", alignment: .leading, type: .body)
                    .padding()
                
                HStack {
                    Spacer()
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
                    Spacer()
                }
                .padding()
                
                HStack {
                    TextHelper.text(key: "Monthly", alignment: .leading, type: .h3)
                    Spacer()
                    if let product = storeManager.products.first(where: { $0.id == "pro1month"}) {
                        TextHelper.text(key: "\(product.displayPrice)/mo", alignment: .trailing, type: .h3, color: Color("Gray200"))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius - 1)
                        .foregroundStyle(Color("Panel"))
                )
                .padding(selectedProductId != "sporadic_pro" ? 2 : 1)
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundStyle(selectedProductId != "sporadic_pro" ? Color("BrandPurple") : .clear)
                )
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundStyle(selectedProductId == "sporadic_pro" ? Color("Gray100") : .clear)
                )
                .padding(selectedProductId == "sporadic_pro" ? 1 : 0)
                .padding()
                .onTapGesture {
                    selectedProductId = "pro1month"
                }
                
                HStack {
                    VStack {
                        TextHelper.text(key: "Lifetime", alignment: .leading, type: .h3)
                        TextHelper.text(key: "Best Offer", alignment: .leading, type: .h6, color: Color("BrandPurple"))
                    }
                    Spacer()
                    if let product = storeManager.products.first(where: { $0.id == "sporadic_pro"}) {
                        TextHelper.text(key: product.displayPrice, alignment: .trailing, type: .h3, color: Color("Gray200"))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius - 1)
                        .foregroundStyle(Color("Panel"))
                )
                .padding(selectedProductId == "sporadic_pro" ? 2 : 1)
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundStyle(selectedProductId == "sporadic_pro" ? Color("BrandPurple") : .clear)
                )
                .background(
                    RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                        .foregroundStyle(selectedProductId != "sporadic_pro" ? Color("Gray100") : .clear)
                )
                .padding(selectedProductId != "sporadic_pro" ? 1 : 0)
                .padding()
                .overlay(
                    VStack {
                        Text("Most popular")
                            .font(.custom("Lexend-SemiBold", size: 10))
                            .padding(10)
                            .foregroundStyle(Color("Gray400"))
                            .background(
                                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                    .foregroundStyle(Color("GroupOption3"))
                            )
                        
                        Spacer()
                    }
                )
                .onTapGesture {
                    selectedProductId = "sporadic_pro"
                }
                
                Spacer()
                
                Button {
                    if let product = storeManager.products.first(where: { $0.id == selectedProductId }) {
                        Task {
                            do {
                                let wasSuccessful = try await storeManager.purchase(product)
                                if wasSuccessful {
                                    dismiss()
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    if let product = storeManager.products.first(where: { $0.id == selectedProductId }) {
                        Group {
                            if product.id == "sporadic_pro" {
                                Text("Purchase Pro Lifetime for \(product.displayPrice)")
                            } else {
                                Text("Subscribe to Pro for \(product.displayPrice)/month")
                            }
                        }
                        .font(Font.custom("Lexend-SemiBold", size: 16, relativeTo: .title))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color("BrandPurple"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        .padding()
                    }
                }
                
                Button(action: {
                    Task {
                        await storeManager.restore()
                    }
                }, label: {
                    TextHelper.text(key: "Restore Purchase", alignment: .center, type: .body, color: Color("BrandPurple"))
                })
                .padding(.bottom)
                
                HStack {
                    Button {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            openURL(url)
                        }
                    } label: {
                        TextHelper.text(key: "Terms of Use", alignment: .trailing, type: .h7)
                    }
                    
                    Text(" | ")
                        .font(Font.custom("Lexend-Regular", size: 12, relativeTo: .caption2))
                        .foregroundColor(Color("Gray200"))

                    Button {
                        if let url = URL(string: "https://sporadic.app/privacy-policy.html") {
                            openURL(url)
                        }
                    } label: {
                        TextHelper.text(key: "Privacy Policy", alignment: .leading, type: .h7)
                    }
                }
                .padding()
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
        .environmentObject(StoreManager())
}
