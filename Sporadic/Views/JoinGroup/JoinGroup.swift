//
//  JoinGroup.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/17/22.
//

import SwiftUI

struct JoinGroup: View {
    @ObservedObject var viewModel: JoinGroupViewModel
    @Environment(\.dismiss) var dismiss
    
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
                            viewModel.joinGroup { didComplete in
                                if didComplete {
                                    dismiss()
                                }
                            }
                        }, label: {
                            TextHelper.text(key: "Accept", alignment: .center, type: .h6, color: .white)
                                .padding()
                                .background(Color("BrandPurple"))
                                .cornerRadius(16)
                        })
                        .buttonStyle(ButtonPressAnimationStyle())
                        .padding()
                        
                        Spacer()
                    }
                }
                .background(Color("Panel"))
                .cornerRadius(16)
                .padding()
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
