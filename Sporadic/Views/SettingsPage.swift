//
//  SettingsPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI
import MessageUI

struct SettingsPage: View {
    @State var a = "a"
    @State var expand = false
    
    @AppStorage(UserPrefs.Measurement.rawValue)
    var measurement = "Imperial"
    
    @AppStorage(UserPrefs.Appearance.rawValue)
    var appTheme = "System"
    
    @State private var isSyncDataPresented = false
    
    //let emailHelper = EmailHelper()
    
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack {
                    Text("Settings")
                        .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
                        .foregroundColor(Color("LooksLikeBlack"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .top])
                        .padding(.bottom, 10)
                    DaysAndTime()
                    VStack (spacing: 25) {
                        HStack {
                            Image("Measurement")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, 5)
                            Text("Measurement")
                                .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                                .foregroundColor(Color("LooksLikeBlack"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(5)
                            OptionPicker(title: "Measurement System", options: ["Imperial", "Metric"], selection: $measurement)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("ActivityBackgroundColor"))
                        .cornerRadius(15)
                        HStack {
                            Image("AppTheme")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, 5)
                            Text("App Theme")
                                .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                                .foregroundColor(Color("LooksLikeBlack"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(5)
                            OptionPicker(title: "Sync Data", options: ["System", "Light", "Dark"], selection: $appTheme)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("ActivityBackgroundColor"))
                        .cornerRadius(15)
                        HStack {
                            Image("Syncing")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, 5)
                            Text("Sync Data")
                                .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                                .foregroundColor(Color("LooksLikeBlack"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(5)
                            Button(action: {
                                isSyncDataPresented.toggle()
                            }, label: {
                                Text("Sync")
                                    .frame(width: 60)
                                    .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
                                    .foregroundColor(Color("SettingButtonTextColor"))
                                    .padding(12)
                                    .background(Color("NiceGray"))
                                    .cornerRadius(10)
                            })
                            .fullScreenCover(isPresented: $isSyncDataPresented, content: FullScreenSyncData.init)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("ActivityBackgroundColor"))
                        .cornerRadius(15)
                        AppIcons()
                        HStack {
                            Image("Support")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, 5)
                            Text("Contact Us")
                                .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                                .foregroundColor(Color("LooksLikeBlack"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(5)
                            Button("Contact") {
                                let email = "brendan@brendanperry.me"
                                if let url = URL(string: "mailto:\(email)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .frame(width: 60)
                            .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
                            .foregroundColor(Color("SettingButtonTextColor"))
                            .padding(12)
                            .background(Color("NiceGray"))
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("ActivityBackgroundColor"))
                        .cornerRadius(15)
                    }
                    .padding()
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
            })
            .padding()
        }
    }
}

struct DaysAndTime: View {
    @AppStorage(UserPrefs.DaysPerWeek.rawValue)
    var daysPerWeek = 3
    
    @AppStorage(UserPrefs.DeliveryDate.rawValue)
    var deliveryDate = Date()
    
    @State var isPresented = false
    
    var body: some View {
        HStack (spacing: 25) {
            VStack {
                Text("Weekly")
                    .font(Font.custom("Gilroy", size: 18, relativeTo: .title2))
                    .foregroundColor(Color("NiceFullGray"))
                Text("Notifications")
                    .font(Font.custom("Gilroy", size: 18, relativeTo: .title2))
                    .foregroundColor(Color("NiceFullGray"))
                Text("\(daysPerWeek)x")
                    .font(Font.custom("Gilroy", size: 34, relativeTo: .title))
                    .foregroundColor(Color("LooksLikeBlack"))
                    .onTapGesture {
                        isPresented.toggle()
                    }
                    .fullScreenCover(isPresented: $isPresented, content: FullScreenDaysPicker.init)
            }
            .frame(height: 75, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(Color("ActivityBackgroundColor"))
            .cornerRadius(15)
            VStack {
                Text("Delivery Time")
                    .font(Font.custom("Gilroy", size: 18, relativeTo: .title))
                    .foregroundColor(Color("NiceFullGray"))
                    .zIndex(1.0)
                ZStack {
                    DatePicker("", selection: $deliveryDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .scaleEffect(1.6)
                    Group {
                        Text(getTime(date: deliveryDate))
                            .font(Font.custom("Gilroy", size: 34, relativeTo: .title)) +
                        Text(" ") +
                        Text(getAmPm(date: deliveryDate))
                            .font(Font.custom("Gilroy", size: 22, relativeTo: .title))
                    }
                    .frame(width: 200, height: 200, alignment: .center)
                    .background(Color("ActivityBackgroundColor"))
                    .userInteractionDisabled()
                }
                .background(Color("ActivityBackgroundColor"))
                .padding(.top, 1)
            }
            .frame(height: 75, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(Color("ActivityBackgroundColor"))
            .cornerRadius(15)
        }
        .padding([.leading, .trailing])
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
                Image("Icon1")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(15)
                    .onTapGesture {
                        UIApplication.shared.setAlternateIconName("AppIcon-1")
                    }
                Image("Icon2")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(15)
                    .onTapGesture {
                        UIApplication.shared.setAlternateIconName("AppIcon-2")
                    }
                Image("Icon3")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(15)
                    .onTapGesture {
                        UIApplication.shared.setAlternateIconName("AppIcon-3")
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(Color("ActivityBackgroundColor"))
        .cornerRadius(15)
    }
}

struct FullScreenSyncData: View {
    @Environment(\.presentationMode) var presentationMode
    
    let steps = "*1.* Go to the Settings app on your phone.\n**2.** Select your profile at the top.\n**3.** Select iCloud.\n**4.** Turn on the toggle for Sporadic."

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
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
                            .font(Font.custom("Gilroy", size: 18, relativeTo: .body))
                            .frame(width: 100, height: 35)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 3)
                                .foregroundColor(.blue)
                            )
                    }
                }
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
    @Environment(\.presentationMode) var presentationMode

    @AppStorage(UserPrefs.DaysPerWeek.rawValue)
    var days = 3

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Picker(selection: $days, label: EmptyView()) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
                    Text("6").tag(6)
                    Text("7").tag(7)
                }
                .labelsHidden()
                .onChange(of: days) { _ in
                    // schedule notifs
                }
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color("ActivityBackgroundColor"))
                            .frame(width: 100, height: 35)
                            .offset(x: 5, y: 5)
                        Text("Close")
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
            .frame(width: 60)
            .font(Font.custom("Gilroy-Medium", size: 14, relativeTo: .body))
            .foregroundColor(Color("SettingButtonTextColor"))
            .padding(12)
            .background(Color("NiceGray"))
            .cornerRadius(10)
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
