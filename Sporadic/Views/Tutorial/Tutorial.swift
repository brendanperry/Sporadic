//
//  Tutorial.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/14/22.
//

import SwiftUI
import PhotosUI
import OneSignalFramework
import Aptabase

enum GroupDifficulty {
    case beginner, intermediate, advanced
}

struct Tutorial: View {
    @State var showImagePicker = false
    @State var selectedphoto: PhotosPickerItem?
    @State var skipGroupCreation = false
    @FocusState var textFieldFocus: Bool
    @StateObject var viewModel = TutorialViewModel()
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .zIndex(-1)
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        withAnimation {
                            Aptabase.shared.trackEvent("tutorial_notifications_skipped")
                            endTutorial()
                        }
                    }, label: {
                        Text("Enable later")
                            .font(.custom("Lexend-Regular", size: 15))
                            .foregroundColor(Color("Gray200"))
                    })
                    .buttonStyle(ButtonPressAnimationStyle())
                    .padding()
                    
                    Spacer()
                }
                .padding(.bottom)
            }
            .disabled(viewModel.selection != 3)
            .opacity(viewModel.selection == 3 ? 1 : 0)
            
            VStack {
                switch viewModel.selection {
                case 1:
                    nameAndPhoto()
                case 2:
                    ExerciseSelectionScreen(selectedTemplates: $viewModel.selectedTemplates)
                case 3:
                    notifications()
                default:
                    openingPage()
                }
                
                VStack {
                    Button(action: {
                        withAnimation {
                            if viewModel.selection == 0 {
                                viewModel.selection += 1
                            }
                            else if viewModel.selection == 1 {
                                if viewModel.name == "" {
                                    viewModel.errorMessage = "Please enter a nickname"
                                    viewModel.showError = true
                                }
                                else {
                                    viewModel.updateUser {
                                        Aptabase.shared.trackEvent("tutorial_user_created")
                                        // If the user redownloads, we can skip creating a new group to avoid making extras
                                        if skipGroupCreation {
                                            viewModel.selection += 2
                                        } else {
                                            viewModel.selection += 1
                                        }
                                    }
                                }
                            }
                            else if viewModel.selection == 2 {
                                viewModel.createGroup()
                                viewModel.selection += 1
                                Aptabase.shared.trackEvent("tutorial_group_created")
                            }
                            else if viewModel.selection == 3 && CloudKitHelper.shared.hasUser() {
                                Aptabase.shared.trackEvent("tutorial_notification_prompted")
                                OneSignal.Notifications.requestPermission { accepted in
                                    Aptabase.shared.trackEvent("tutorial_notification_result", with: ["accepted": accepted])
                                    if let userId = CloudKitHelper.shared.getCachedUser()?.usersRecordId {
                                        OneSignal.login(userId)
                                    }
                                    
                                    endTutorial()
                                }
                            }
                        }
                    }, label: {
                        Image("TutorialArrow")
                            .resizable()
                            .frame(width: 60, height: 60, alignment: .center)
                            .hoverEffect()
                    })
                    .buttonStyle(ButtonPressAnimationStyle())
                    .opacity(viewModel.selectedTemplates.count < 3 && viewModel.selection == 2 ? 0.5 : 1)
                    .disabled(viewModel.selectedTemplates.count < 3 && viewModel.selection == 2)
                    
                    HStack {
                        Capsule()
                            .frame(width: viewModel.selection == 0 ? 20 : 10, height: 10, alignment: .leading)
                            .foregroundColor(viewModel.selection == 0 ? Color("Gray400AutoTheme") : Color("Deep Blue 200"))
                        Capsule()
                            .frame(width: viewModel.selection == 1 ? 20 : 10, height: 10, alignment: .center)
                            .foregroundColor(viewModel.selection == 1 ? Color("Gray400AutoTheme") : Color("Deep Blue 200"))
                        Capsule()
                            .frame(width: viewModel.selection == 2 ? 20 : 10, height: 10, alignment: .center)
                            .foregroundColor(viewModel.selection == 2 ? Color("Gray400AutoTheme") : Color("Deep Blue 200"))
                        Capsule()
                            .frame(width: viewModel.selection == 3 ? 20 : 10, height: 10, alignment: .center)
                            .foregroundColor(viewModel.selection == 3 ? Color("Gray400AutoTheme") : Color("Deep Blue 200"))
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding(.top)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding([.horizontal, .top])
            
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .preferredColorScheme(ColorSchemeHelper().getColorSceme())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .task {
            guard let groups = try? await CloudKitHelper.shared.getGroupsForUser() else { return }
            
            if groups.count > 0 {
                skipGroupCreation = true
            }
        }
        .alert("Oops", isPresented: $viewModel.showError, actions: {
            Button("Okay") {
                viewModel.showError = false
            }
        }) {
            Text(viewModel.errorMessage)
        }
    }
    
    func endTutorial() {
        Aptabase.shared.trackEvent("tutorial_completed")
        viewRouter.navigateTo(.home)
        UserDefaults.standard.setValue(true, forKey: UserPrefs.tutorial.rawValue)
    }
    
    func openingPage() -> some View {
        VStack {
            Image("TutorialBackground1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            TextHelper.text(key: "StayActive", alignment: .leading, type: .h1)
                .padding(.vertical)
            
            TextHelper.text(key: "Receive random exercise challenges throughout your week, personalized to you.", alignment: .leading, type: .body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func challengeExplanation() -> some View {
        VStack {
            HStack {
                Image("TutorialActivity")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .top, .trailing])
                
                Image("TutorialSlider")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding([.trailing, .top])
            }
            
            TextHelper.text(key: "Get started 🚀", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "You will be challenged with exercises from your group. Each exercise has a difficulty range the challenge will be chosen from.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func difficultySelector() -> some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName: "gear")
                    
                    Spacer()
                    
                    Text("2 challenges per week")
                        .font(Font.custom("Lexend-Regular", size: 10, relativeTo: .footnote))
                        .foregroundColor(Color("Gray400"))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                .foregroundColor(Color("Gray100"))
                        )
                }
                
                TextHelper.text(key: "Beginner", alignment: .leading, type: .h3)
                    .padding(.vertical, 3)
                
                TextHelper.text(key: "Includes jumping jacks, push-ups, walking, and running at an easier difficulty", alignment: .leading, type: .body)
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                    .strokeBorder(viewModel.selectedDifficulty == .beginner ? Color("BrandBlue") : .clear)
            )
            .onTapGesture {
                withAnimation {
                    viewModel.selectedDifficulty = .beginner
                }
            }
            
            VStack {
                HStack {
                    Image(systemName: "gear")
                    
                    Spacer()
                    
                    Text("4 challenges per week")
                        .font(Font.custom("Lexend-Regular", size: 10, relativeTo: .footnote))
                        .foregroundColor(Color("Gray400"))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                .foregroundColor(Color("Gray100"))
                        )
                }
                
                TextHelper.text(key: "Intermediate", alignment: .leading, type: .h3)
                    .padding(.vertical, 3)
                
                TextHelper.text(key: "Includes crunches, push-ups, walking, planks, and running at a medium difficulty.", alignment: .leading, type: .body)
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                    .strokeBorder(viewModel.selectedDifficulty == .intermediate ? Color("BrandBlue") : .clear)
            )
            .onTapGesture {
                withAnimation {
                    viewModel.selectedDifficulty = .intermediate
                }
            }
            
            VStack {
                HStack {
                    Image(systemName: "gear")
                    
                    Spacer()
                    
                    Text("6 challenges per week")
                        .font(Font.custom("Lexend-Regular", size: 10, relativeTo: .footnote))
                        .foregroundColor(Color("Gray400"))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                                .foregroundColor(Color("Gray100"))
                        )
                }
                
                TextHelper.text(key: "Advanced", alignment: .leading, type: .h3)
                    .padding(.vertical, 3)
                
                TextHelper.text(key: "Includes running, wall sits, squats, burpes, planks, and push-ups at a harder difficulty.", alignment: .leading, type: .body)
            }
            .padding()
            .background(Color("Panel"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius)
            .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: GlobalSettings.shared.controlCornerRadius)
                    .strokeBorder(viewModel.selectedDifficulty == .advanced ? Color("BrandBlue") : .clear)
            )
            .onTapGesture {
                withAnimation {
                    viewModel.selectedDifficulty = .advanced
                }
            }
            
            TextHelper.text(key: "Pick a preset", alignment: .leading, type: .h1)
                .padding(.vertical)
            
            TextHelper.text(key: "We want to help you get started. You can fully customize this group afterwards.", alignment: .leading, type: .body)
            
            Spacer()
        }
        .padding([.horizontal, .top])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func nameAndPhoto() -> some View {
        VStack {
            ZStack {
                Image("TutorialBackground2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack {
                    VStack {
                        ZStack {
                            Image(uiImage: viewModel.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75, alignment: .center)
                                .cornerRadius(100)
                            
                            EditIcon()
                                .hoverEffect()
                                .offset(x: 25, y: -25)
                                .photosPicker(isPresented: $showImagePicker, selection: $selectedphoto, matching: .images, photoLibrary: .shared())
                                .onChange(of: selectedphoto) { newValue in
                                    Task {
                                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                            DispatchQueue.main.async {
                                                viewModel.photo = UIImage(data: data)
                                            }
                                        }
                                    }
                                }
                        }
                        .onTapGesture {
                            showImagePicker = true
                        }
                        .hoverEffect()

                        if viewModel.photo != nil {
                            Button(action: {
                                viewModel.photo = nil
                                selectedphoto = nil
                            }, label: {
                                Text("Remove")
                                    .font(Font.custom("Lexend-Regular", size: 15, relativeTo: .caption))
                                    .foregroundColor(Color("Failed"))
                            })
                            .hoverEffect()
                        }
                    }
                    .padding(.bottom)
                    
                    HStack(spacing: 0) {
                        Text("Nickname")
                            .foregroundColor(Color("Gray300"))
                        Text("*")
                            .foregroundColor(Color("Failed"))
                        Spacer()
                    }
                    .font(Font.custom("Lexend-SemiBold", size: 15, relativeTo: .title3))

                    TextField("", text: $viewModel.name.max(24))
                        .autocorrectionDisabled()
                        .padding()
                        .frame(minWidth: 200, alignment: .leading)
                        .background(Color("Deep Blue 200 And White"))
                        .cornerRadius(16)
                        .font(Font.custom("Lexend-Regular", size: 14))
                        .foregroundColor(Color("Gray300"))
                        .focused($textFieldFocus)
                        .onTapGesture {
                            textFieldFocus = true
                        }
                        .hoverEffect()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            }
            
            TextHelper.text(key: "Introduce yourself", alignment: .leading, type: .h1)
                .padding(.vertical)
            
            TextHelper.text(key: "There’s no account required. A name and photo will help your friends recognize you.", alignment: .leading, type: .body)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func notifications() -> some View {
        VStack {
            Spacer()
            
            Image("TutorialBackground3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            TextHelper.text(key: "Get notifications for your challenges 🔔", alignment: .leading, type: .h1)
                .padding(.vertical)
            
            TextHelper.text(key: "We need your permission to send notifications when your exercise challenges are ready. We will only send notifications for your challenges and when your other group members have completed challenges.", alignment: .leading, type: .body)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
    
    func inviteFriends() -> some View {
        VStack {
            VStack {
                Image(uiImage: viewModel.photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75, alignment: .center)
                    .cornerRadius(100)
                    .padding()
                
                TextHelper.text(key: "Join me in Sporadic and let’s complete exercise challenges together!", alignment: .center, type: .body, color: .white)
                
                ShareLink(item: "https://sporadic.app/?group=\(viewModel.group.record.recordID.recordName)", message: Text("Join \(viewModel.group.name) on Sporadic!"), label: {
                    Text("Invite Friends")
                        .font(.custom("Lexend-Regular", size: 12))
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .padding(.horizontal)
                        .background(Color("BrandPurple"))
                        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
                        .padding()
                })
                .buttonStyle(ButtonPressAnimationStyle())
                .frame(maxWidth: .infinity)
            }
            .background(
                Image("InviteBackground")
                    .resizable()
                    .frame(maxWidth: .infinity)
            )
            .padding()
            
            TextHelper.text(key: "Complete challenges with friends", alignment: .leading, type: .h1)
                .padding()
            
            TextHelper.text(key: "Invite your friends and complete challenges together! Or go solo and rock it out.", alignment: .leading, type: .body)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.backslide)
    }
}
