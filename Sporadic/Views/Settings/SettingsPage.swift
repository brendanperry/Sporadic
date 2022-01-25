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
    
    let viewModel: SettingsViewModel
    
    init() {
        viewModel = SettingsViewModel(notificationHelper: NotificationHelper(context: DataController.shared.controller.viewContext))
    }

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 20) {
                    textHelper.GetTextByType(text: "Settings", isCentered: false, type: TextType.largeTitle)
                    
                    DaysAndTime(viewModel: viewModel, days: $days, time: $time)
                    
                    RectangleWidget(
                        image: "NotificationIcon",
                        text: "Notifications",
                        actionText: "Prompt",
                        actionView: AnyView(NotificationButton()))
                    
                    RectangleWidget(
                        image: "AppTheme",
                        text: "App Theme",
                        actionText: appTheme,
                        actionView: AnyView(
                            OptionPicker(title: "App Theme", options: appThemeOptions, selection: $appTheme)))
                        
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
        }
    }
    
    struct NotificationButton: View {
        var body: some View {
            Button(action: {
                UNUserNotificationCenter
                    .current()
                    .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }, label: {
                Text("Prompt")
            })
            .withSettingsButtonStyle()
        }
    }

    struct ContactButton: View {
        var body: some View {
            Button("Contact") {
                let email = "contact@brendanperry.me"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            }
            .withSettingsButtonStyle()
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
                
                textHelper.GetTextByType(text: text, isCentered: false, type: TextType.body)
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
                        
                        ZStack {
                            Picker(selection: $days, label: EmptyView()) {
                                ForEach(1...7, id: \.self) { number in
                                    Text(String(number))
                                }
                            }
                            .labelsHidden()
                            .onChange(of: days) { _ in
                                viewModel.scheduleNotifications()
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
                                .onChange(of: time) { _ in
                                    viewModel.scheduleNotifications()
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
                    
                    textHelper.GetTextByType(text: "App Icon", isCentered: false, type: TextType.body)
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
            VStack {
                Button(selection) {
                    showingOptions = true
                }
                .withSettingsButtonStyle()
                .actionSheet(isPresented: $showingOptions) {
                    ActionSheet(
                        title: Text(title),
                        buttons: options.map { option in
                            .default(Text(option)) {
                                selection = option
                            }
                        }
                    )
                }
            }
        }
    }
}


struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage().preferredColorScheme(.dark)
    }
}
