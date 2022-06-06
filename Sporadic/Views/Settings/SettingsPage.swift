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

    @AppStorage(UserPrefs.daysPerWeek.rawValue)
    var days = 3

    @AppStorage(UserPrefs.deliveryTime.rawValue)
    var time = Date()
    
    let appThemeOptions = ["System", "Light", "Dark"]
    
    let textHelper = TextHelper()
    
    @ObservedObject var viewModel: SettingsViewModel
    
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    init() {
        viewModel = SettingsViewModel(notificationHelper: NotificationHelper(cloudKitHelper: CloudKitHelper.shared))
    }

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 20) {
                    textHelper.GetTextByType(key: "Settings", alignment: .leading, type: TextType.activityTitle)
                    
                    DaysAndTime(viewModel: viewModel, days: $days, time: $time)
                    
                    RectangleWidget(
                        image: "NotificationIcon",
                        text: "Notifications",
                        actionText: "Prompt",
                        actionView: AnyView(NotificationButton(viewModel: viewModel)))
                        .alert(isPresented: $viewModel.showDisabledAlert) {
                            Alert(title: Text(Localize.getString("NotificationsDisabled")), message: Text(Localize.getString("PleaseEnableNotifications")), dismissButton: .default(Text(Localize.getString("Okay"))))
                        }
                    
                    RectangleWidget(
                        image: "AppTheme",
                        text: "App Theme",
                        actionText: appTheme,
                        actionView: AnyView(OptionPicker(title: Localize.getString("AppTheme"), options: appThemeOptions, selection: $appTheme)))
                        .alert(isPresented: $viewModel.showEnabledAlert) {
                            Alert(title: Text(Localize.getString("NotificationsEnabled")), message: Text(Localize.getString("NothingToDo")), dismissButton: .default(Text(Localize.getString("Okay"))))
                        }
                        
                    AppIcons()
                    
                    RectangleWidget(
                        image: "Support",
                        text: "Contact Us",
                        actionText: "Contact",
                        actionView: AnyView(ContactButton()))
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 100, height: 100, alignment: .bottom)
                }
                .padding()
            })
            .padding(.top)
            .preferredColorScheme(ColorSchemeHelper().getColorSceme())
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
//                    GlobalSettings.Env.scheduleNotificationsIfNoneExist()
                }
            }
        }
        
        NavigationBar(viewRouter: viewRouter)
    }
    
    struct NotificationButton: View {
        let viewModel: SettingsViewModel
        
        var body: some View {
            Button(action: {
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
            }, label: {
                Text("Prompt")
                    .frame(minWidth: 60)
                    .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
                    .foregroundColor(Color("SettingButtonTextColor"))
                    .padding(12)
                    .background(Color("SettingsButtonBackgroundColor"))
                    .cornerRadius(10)
            })
                .buttonStyle(ButtonPressAnimationStyle())
        }
    }

    struct ContactButton: View {
        var body: some View {
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                let email = "contact@sporadic.app"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            }, label: {
                Text("Contact")
                    .frame(minWidth: 60)
                    .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
                    .foregroundColor(Color("SettingButtonTextColor"))
                    .padding(12)
                    .background(Color("SettingsButtonBackgroundColor"))
                    .cornerRadius(10)
            })
                .buttonStyle(ButtonPressAnimationStyle())
        }
    }

    struct RectangleWidget: View {
        let image: String
        let text: String
        let actionText: String
        let actionView: AnyView
        let textHelper = TextHelper()

        var body: some View {
            HStack {
                Image(image)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 5)
                
                textHelper.GetTextByType(key: "", alignment: .leading, type: TextType.body, prefix: text)
                    .padding(5)
                
                actionView
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color("ActivityBackgroundColor"))
            .cornerRadius(15)
        }
    }

    struct DaysAndTime: View {
        let dateHelper = DateHelper()
        let viewModel: SettingsViewModel

        @Binding var days: Int
        @Binding var time: Date

        @State var isPresented = false

        var body: some View {
            HStack(spacing: 25) {
                Group {
                    VStack {
                        Text("Weekly\nNotifications")
                            .frame(height: 50)
                            .multilineTextAlignment(.center)
                            .font(Font.custom("Gilroy", size: 18, relativeTo: .title3))
                            .foregroundColor(Color("SettingButtonTextColor"))
                            .offset(y: 10)

                        ZStack {
                            Picker(selection: $days, label: EmptyView()) {
                                ForEach(1...7, id: \.self) { number in
                                    Text(String(number))
                                }
                            }
                            .frame(width: 125, height: 50, alignment: .center)
                            .labelsHidden()
                            .onChange(of: days) { _ in
                                viewModel.scheduleNotifications(settingsChanged: true)
                            }

                            Text("\(days)")
                                .font(Font.custom("Gilroy", size: 34, relativeTo: .title2))
                                .frame(width: 200, height: 50, alignment: .center)
                                .background(Color("ActivityBackgroundColor"))
                                .userInteractionDisabled()
                        }
                    }
                    VStack {
                        Text("Delivery Time")
                            .font(Font.custom("Gilroy", size: 18, relativeTo: .title3))
                            .foregroundColor(Color("SettingButtonTextColor"))
                            .zIndex(1.0)

                        ZStack {
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .scaleEffect(1.6)
                                .frame(width: 125)
                                .onChange(of: time) { _ in
                                    viewModel.scheduleNotifications(settingsChanged: true)
                                }

                            Group {
                                Text(dateHelper.getHoursAndMinutes(date: time))
                                    .font(Font.custom("Gilroy", size: 34, relativeTo: .title2)) +
                                Text(" ") +
                                Text(dateHelper.getAmPm(date: time))
                                    .font(Font.custom("Gilroy", size: 22, relativeTo: .title2))
                            }
                            .frame(width: 200, height: 200, alignment: .center)
                            .background(Color("ActivityBackgroundColor"))
                            .userInteractionDisabled()
                        }
                        .background(Color("ActivityBackgroundColor"))
                        .padding(.top, 1)
                    }
                }
                .frame(height: 75, alignment: .center)
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(Color("ActivityBackgroundColor"))
                .cornerRadius(15)
            }
        }
    }

    struct AppIcons: View {
        var textHelper = TextHelper()
        
        var body: some View {
            VStack {
                HStack {
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 5)
                    
                    textHelper.GetTextByType(key: "AppIcon", alignment: .leading, type: TextType.body)
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
            .background(Color("ActivityBackgroundColor"))
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

    struct OptionPicker: View {
        var title: String
        var options: [String]
        
        @Binding var selection: String
        @State var showingOptions = false
        
        var body: some View {
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                showingOptions = true
            }, label: {
                Text(selection)
                    .frame(minWidth: 60)
                    .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
                    .foregroundColor(Color("SettingButtonTextColor"))
                    .padding(12)
                    .background(Color("SettingsButtonBackgroundColor"))
                    .cornerRadius(10)
            })
                .buttonStyle(ButtonPressAnimationStyle())
                .actionSheet(isPresented: $showingOptions) {
                    ActionSheet(
                        title: Text(title),
                        buttons: options.map { option in
                                .default(Text(option)) {
                                    selection = option
                                }
                        })
                }
        }
    }
}


struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsPage().preferredColorScheme(.dark)
            SettingsPage().previewDevice("iPhone 13 Pro Max").preferredColorScheme(.light)
        }
    }
}
