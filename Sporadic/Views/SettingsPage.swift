//
//  SettingsPage.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI

struct SettingsPage: View {
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Settings")
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
                DaysPerWeek()
            }
        }
    }
}

struct DaysPerWeek: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    @State var deliveryDate = "9:30 AM"
    @AppStorage(UserPrefs.DaysPerWeek.rawValue) var days = 3.0
    @AppStorage(UserPrefs.DeliveryDate.rawValue) var date = Date()
    
    var body: some View {
        VStack {
            Text(Localize.getString("RandomNotificationDelivery"))
            Text("\(days) " + Localize.getString("TimesAWeek"))
            Slider(value: $days, in: 1...7,step: 1)
            .onChange(of: days, perform: { tag in
                let impact = UIImpactFeedbackGenerator(style: .rigid)
                impact.impactOccurred()
                
                activityViewModel.scheduleNotifs()
            })
            ZStack {
                Text("1")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("7")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            ZStack {
                DatePicker("Please enter a time: ", selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: date, perform: { tag in
                        print(date)
                        deliveryDate = self.getFormattedDate(date: date)
                        
                        activityViewModel.scheduleNotifs()
                    })
                Text(deliveryDate)
                    .userInteractionDisabled()
                }
        }
        .padding()
        .onAppear() {
            deliveryDate = self.getFormattedDate(date: date)
        }
    }
    
    func getFormattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        return dateFormatter.string(from: date)
    }
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
