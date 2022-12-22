//
//  JoinGroup.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/17/22.
//

import SwiftUI

struct JoinGroup: View {
    @StateObject var viewModel: JoinGroupViewModel
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
                        TextHelper.text(key: "You've been invited to join a group!", alignment: .center, type: .h2)
                        TextHelper.text(key: "Would you like to join?", alignment: .center, type: .h2)
                    }
                    .padding(.top)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }, label: {
                            TextHelper.text(key: "Don't Join", alignment: .center, type: .h2, color: .white)
                                .padding()
                                .background(Color("Delete"))
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
                            TextHelper.text(key: "Join Group", alignment: .center, type: .h2, color: .white)
                                .padding()
                                .background(Color("Primary"))
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
                
                // oof
//                UsersInGroup(users: viewModel.group.use, group: <#T##UserGroup#>)
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
