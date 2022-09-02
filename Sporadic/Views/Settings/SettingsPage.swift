//
//  SettingsPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct SettingsPage: View {
    @AppStorage(UserPrefs.measurement.rawValue)
    var measurement = "Imperial"
    
    @AppStorage(UserPrefs.appearance.rawValue)
    var appTheme = "System"
    
    @AppStorage(UserPrefs.deliveryTime.rawValue)
    var time = Date()
    
    let appThemeOptions = ["System", "Light", "Dark"]
    
    @State var showThemeOptions = false
    
    @ObservedObject var viewModel: SettingsViewModel
    
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    init() {
        viewModel = SettingsViewModel()
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 20) {
                    TextHelper.text(key: "Settings", alignment: .leading, type: .h1)
                        .padding(.top, 50)
                        .padding(.bottom)
                    
                    UserSettings(viewModel: viewModel, name: $viewModel.name, photo: $viewModel.photo)
                    NotificationWidget()
                    AppTheme()
                    AppIcons()
                    Contact()
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            })
            .preferredColorScheme(ColorSchemeHelper().getColorSceme())
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    //                    GlobalSettings.Env.scheduleNotificationsIfNoneExist()
                }
            }
            .padding(.top)
            
            NavigationBar(viewRouter: viewRouter)
        }
    }
    
    func NotificationWidget() -> some View {
        RectangleWidget(
            image: "NotificationIcon",
            text: "Notifications",
            actionText: "Prompt") {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        }
                        
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            DispatchQueue.main.async {
                                if settings.authorizationStatus == .authorized {
                                    viewModel.showEnabledAlert = true
                                    viewModel.scheduleNotifications(settingsChanged: false)
                                } else {
                                    viewModel.showDisabledAlert = true
                                }
                            }
                        }
                    }
            }
            .alert(isPresented: $viewModel.showDisabledAlert) {
                Alert(title: Text(Localize.getString("NotificationsDisabled")), message: Text(Localize.getString("PleaseEnableNotifications")), dismissButton: .default(Text(Localize.getString("Okay"))))
            }
    }
    
    func AppTheme() -> some View {
        RectangleWidget(
            image: "AppTheme",
            text: "App Theme",
            actionText: appTheme) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                showThemeOptions = true
            }
            .alert(isPresented: $viewModel.showEnabledAlert) {
                Alert(title: Text(Localize.getString("NotificationsEnabled")), message: Text(Localize.getString("NothingToDo")), dismissButton: .default(Text(Localize.getString("Okay"))))
            }
            .buttonStyle(ButtonPressAnimationStyle())
            .actionSheet(isPresented: $showThemeOptions) {
                ActionSheet(
                    title: Text(Localize.getString("AppTheme")),
                    buttons: appThemeOptions.map { option in
                            .default(Text(option)) {
                                appTheme = option
                            }
                    })
            }
    }
    
    func Contact() -> some View {
        RectangleWidget(
            image: "Support",
            text: "Contact Us",
            actionText: "Contact") {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                let email = "contact@sporadic.app"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            }
    }
    
    struct UserSettings: View {
        @State var showImagePicker = false
        @ObservedObject var viewModel: SettingsViewModel
        @Binding var name: String
        @Binding var photo: UIImage?
        let textHelper = TextHelper()
        
        var body: some View {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        ZStack {
                            Image(uiImage: photo ?? UIImage(imageLiteralResourceName: "Default Profile"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75, alignment: .center)
                                .cornerRadius(100)
                                .padding(.leastNormalMagnitude)
                            
                            Image("Edit Group Icon")
                                .resizable()
                                .frame(width: 15, height: 15, alignment: .center)
                                .background(
                                    Circle()
                                        .foregroundColor(Color("EditProfile"))
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .offset(x: -1, y: -1)
                                )
                                .offset(x: 25, y: -25)
                                .onTapGesture {
                                    showImagePicker = true
                                }
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePicker(image: $photo)
                                }
                                .onChange(of: photo) { _ in
                                    viewModel.updateUserImage()
                                }
                        }
                        
                        TextField("", text: $name)
                            .padding()
                            .frame(minWidth: 200, maxHeight: 50, alignment: .leading)
                            .background(Color("Panel"))
                            .cornerRadius(16)
                            .font(Font.custom("Lexend-Regular", size: 14))
                            .foregroundColor(Color("Header"))
                            .padding(.leading)
                            .onSubmit {
                                viewModel.updateUserName()
                            }
                    }
                    
                    Button(action: {
                        print("Remove")
                        photo = nil
                        viewModel.updateUserImage()
                    }, label: {
                        TextHelper.text(key: "Remove", alignment: .center, type: .challengeGroup)
                    })
                    .frame(maxWidth: 75, maxHeight: 25)
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Uh-Oh!"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Okay")))
            }
        }
    }
    
    struct RectangleWidget: View {
        let image: String
        let text: String
        let actionText: String
        let action: () -> Void
        
        var body: some View {
            HStack {
                Image(image)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 5)
                
                TextHelper.text(key: "", alignment: .leading, type: .challengeAndSettings, prefix: text)
                    .padding(5)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color("Panel"))
            .cornerRadius(15)
            .onTapGesture {
                action()
            }
        }
    }
    
    struct AppIcons: View {
        var body: some View {
            VStack {
                HStack {
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 5)
                    
                    TextHelper.text(key: "AppIcon", alignment: .leading, type: TextType.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 50) {
                    AppIcon(name: "AppIcon-1")
                    AppIcon(name: "AppIcon-2")
                    AppIcon(name: "AppIcon-3")
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color("Panel"))
            .cornerRadius(15)
        }
        
        struct AppIcon: View {
            let name: String
            
            var body: some View {
                Image(name)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(15)
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        
                        if name == "AppIcon-1" {
                            UIApplication.shared.setAlternateIconName(nil)
                        } else {
                            UIApplication.shared.setAlternateIconName(name)
                        }
                    }
            }
        }
    }
}
