//
//  SettingsPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct SettingsPage: View {
    @AppStorage(UserPrefs.Measurement.rawValue)
    var measurement = "Imperial"
    
    @AppStorage(UserPrefs.Appearance.rawValue)
    var appTheme = "System"
    
    @AppStorage(UserPrefs.DaysPerWeek.rawValue)
    var days = 3
    
    @AppStorage(UserPrefs.DeliveryTime.rawValue)
    var time = Date()
    
    let measurementOptions = ["Imperial", "Metric"]
    let appThemeOptions = ["System", "Light", "Dark"]
            
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
                        .foregroundColor(Color("LooksLikeBlack"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    DaysAndTime(days: $days, time: $time)
                    RectangleWidget(image: "Measurement", text: "Measurement", actionText: measurement, ActionView: AnyView(OptionPicker(title: "Measurement", options: measurementOptions, selection: $measurement)))
                    RectangleWidget(image: "AppTheme", text: "App Theme", actionText: appTheme, ActionView: AnyView(OptionPicker(title: "App Theme", options: appThemeOptions, selection: $appTheme)))
                    RectangleWidget(image: "Syncing", text: "Sync Data", actionText: "Sync", ActionView: AnyView(SyncButton()))
                    AppIcons()
                    RectangleWidget(image: "Support", text: "Contact Us", actionText: "Contact", ActionView: AnyView(ContactButton()))
                    NotificationButton()
                }
                .padding()
            })
            .padding(.top)
        }
    }
}

struct NotificationButton: View {
    var body: some View {
        Button(action: {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }, label: {
            Text("Request Notification Access")
        })
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

struct SyncButton: View {
    @State private var isSyncDataPresented = false

    var body: some View {
        Button("Sync") {
            isSyncDataPresented.toggle()
        }
        .withSettingsButtonStyle()
        .fullScreenCover(isPresented: $isSyncDataPresented, content: FullScreenSyncData.init)
    }
}

struct RectangleWidget: View {
    let image: String
    let text: String
    let actionText: String
    let ActionView: AnyView
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.horizontal, 5)
            Text(text)
                .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                .foregroundColor(Color("LooksLikeBlack"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5)
            ActionView
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(Color("ActivityBackgroundColor"))
        .cornerRadius(15)
    }
}

struct DaysAndTime: View {
    @Binding var days: Int
    @Binding var time: Date
    
    @State var isPresented = false
    
    var body: some View {
        HStack (spacing: 25) {
            Group {
                VStack {
                    Text("Weekly\nNotifications")
                        .frame(height: 50)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("Gilroy", size: 18, relativeTo: .title3))
                        .foregroundColor(Color("SettingButtonTextColor"))
                    Button("\(days)x") {
                        isPresented.toggle()
                    }
                    .font(Font.custom("Gilroy", size: 34, relativeTo: .title2))
                    .foregroundColor(Color("LooksLikeBlack"))
                    .fullScreenCover(isPresented: $isPresented, content: {
                        FullScreenDaysPicker(days: $days)
                    })
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
                        Group {
                            Text(getTime(date: time))
                                .font(Font.custom("Gilroy", size: 34, relativeTo: .title2)) +
                            Text(" ") +
                            Text(getAmPm(date: time))
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
    var body: some View {
        VStack {
            HStack {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 5)
                Text("App Icon")
                    .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                    .foregroundColor(Color("LooksLikeBlack"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack (spacing: 50) {
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
                    UIApplication.shared.setAlternateIconName(name)
                }
        }
    }
}

struct FullScreenSyncData: View {
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text("It's a great idea to sync your data! This will keep your settings and stats safe even if you lose your phone.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .body))
                    .foregroundColor(Color("LooksLikeBlack"))
                    .padding()
                Text("Steps:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.custom("Gilroy", size: 22, relativeTo: .title3))
                    .foregroundColor(Color("LooksLikeBlack"))
                    .padding()
                ListItem(number: "1. ", text: "Go to the Settings app on your phone.")
                ListItem(number: "2. ", text: "Select your profile at the top.")
                ListItem(number: "3. ", text: "Select iCloud.")
                ListItem(number: "4. ", text: "Turn on the toggle for Sporadic.")
                Text("That's it! Now you can get back to your challenge with peace of mind.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .body))
                    .foregroundColor(Color("LooksLikeBlack"))
                    .padding()
                Spacer()
                DoneButton()
            }
            .padding()
        }
    }
    
    struct ListItem: View {
        var number: String
        var text: String
        
        var body: some View {
            Group {
                Text(number)
                    .font(Font.custom("Gilroy", size: 18, relativeTo: .body)) +
                Text(text)
                    .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .title3))
            }
            .foregroundColor(Color("LooksLikeBlack"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 1)
            .padding([.bottom, .horizontal])
        }
    }
}

struct FullScreenDaysPicker: View {
    @Binding var days: Int
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Picker(selection: $days, label: EmptyView()) {
                    ForEach(1...7, id:\.self){ i in
                        Text(String(i))
                    }
                }
                .labelsHidden()
                .onChange(of: days) { _ in
                    // schedule notifs
                    print(days)
                }
                DoneButton()
            }
        }
    }
}

struct DoneButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color("ActivityBackgroundColor"))
                    .frame(width: 100, height: 35)
                    .offset(x: 5, y: 5)
                Text("Done")
                    .foregroundColor(Color("BlackWhiteColor"))
                    .bold()
                    .frame(width: 100, height: 35)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 3)
                        .foregroundColor(.blue)
                    )
            }
        }
    }
}
    

struct OptionPicker: View {
    var title: String
    var options: [String]
    
    @Binding var selection : String
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

extension Button {
    func withSettingsButtonStyle() -> some View {
        self.frame(width: 60)
        .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
        .foregroundColor(Color("SettingButtonTextColor"))
        .padding(12)
        .background(Color("SettingsButtonBackgroundColor"))
        .cornerRadius(10)
    }
}

func getFormattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: date)
}

func getTime(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm"
    return dateFormatter.string(from: date)
}

func getAmPm(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "a"
    return dateFormatter.string(from: date)
}

struct NoHitTesting: ViewModifier {
    func body(content: Content) -> some View {
        SwiftUIWrapper { content }.allowsHitTesting(false)
    }
}

extension View {
    func userInteractionDisabled() -> some View {
        self.modifier(NoHitTesting())
    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}

struct SettingsPage_Previews: PreviewProvider {
    static let activityViewModel = ActivityViewModel()
    
    static var previews: some View {
        SettingsPage().preferredColorScheme(.dark).environmentObject(activityViewModel)
    }
}
