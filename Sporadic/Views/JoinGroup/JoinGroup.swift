//
//  JoinGroup.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/17/22.
//

import SwiftUI
import Aptabase

struct JoinGroup: View {
    let groupCount: Int
    @ObservedObject var viewModel: JoinGroupViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @Binding var groupId: String
    @State var showProPopUp = false
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 75, height: 75, alignment: .leading)
                        .foregroundColor(GroupBackgroundColor.init(rawValue: viewModel.group?.backgroundColor ?? 0)?.getColor())
                    
                    Text(viewModel.group?.emoji ?? "")
                        .font(.system(size: 40))
                }
                
                TextHelper.text(key: viewModel.group?.name ?? "", alignment: .center, type: .h1)
                
                VStack {
                    VStack {
                        TextHelper.text(key: "You've been invited to join a group.", alignment: .center, type: .h5)
                        TextHelper.text(key: "Would you like to join?", alignment: .center, type: .h5)
                    }
                    .padding(.top)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }, label: {
                            TextHelper.text(key: "Decline", alignment: .center, type: .h6, color: Color("CancelText"))
                                .padding()
                                .background(Color("Cancel"))
                                .cornerRadius(16)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            if storeManager.isPro || groupCount <= 1 {
                                viewModel.joinGroup { didComplete in
                                    if didComplete {
                                        dismiss()
                                    }
                                }
                            } else {
                                Aptabase.shared.trackEvent("pro_popup_join_group_triggered")
                                showProPopUp = true
                            }
                        }, label: {
                            TextHelper.text(key: "Accept", alignment: .center, type: .h6, color: .white)
                                .padding()
                                .background(Color("BrandPurple"))
                                .cornerRadius(16)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .padding()
                        .popover(isPresented: $showProPopUp) {
                            Paywall(shouldShow: $showProPopUp)
                        }
                        
                        Spacer()
                    }
                }
                .background(Color("Panel"))
                .cornerRadius(16)
                .padding()
                .onDisappear {
                    groupId = ""
                }
            }
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay"), action: {
                dismiss()
            }))
        }
    }
}
